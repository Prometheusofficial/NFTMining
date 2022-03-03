// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interface/IERC721.sol";

import "../interface/IPancakeRouter.sol";
import "../interface/IBattleNFT.sol";
import "../interface/IGodNFT.sol";
import "../utils/Manageable.sol";

interface IConfigMining{
    function getCheckListLength(uint256 _gaimID) external view returns(uint256);
    function getAttributesVaule(uint256 _gaimID,uint256 _index) external view returns(uint256 _Attribute,uint256 _vaule);
    function isValidGameID(uint256 _gaimID) external view returns(bool);
}

contract NFTMining is Manageable{
    
    using SafeMath for *;
    using SafeERC20 for IERC20;
    
    IBattleNFT immutable public batterNFT = IBattleNFT(0x378aC3870Ff0D0d28308e934a666a52752b55DB8);
    IGodNFT immutable public godNFT = IGodNFT(0xd34Eb2d530245a60C6151B6cfa6D247Ee92668c7);
    IERC20  public rewardToken = IERC20(0x03aC6AB6A9a91a0fcdec7D85b38bDFBb719ec02f);
    IPancakeRouter immutable public router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20 public immutable USDT = IERC20(0x55d398326f99059fF775485246999027B3197955); // this is USDT
    IERC20 public immutable mga = IERC20(0x03aC6AB6A9a91a0fcdec7D85b38bDFBb719ec02f); // this is MGA
    //test
    /*
    IPancakeRouter public router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBattleNFT public batterNFT = IBattleNFT(0x3Bd00BBD07E18743bFfb7589E2eE89FFd695f642);
    IGodNFT public godNFT = IGodNFT(0xD4fD679fA138589e81148bb2Dac6f0E8631e404e);
    IERC20 public rewardToken = IERC20(0xE36339cC77A7b155d7BC0543223D97831e5F60E9); // this is mga 
    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955); // this is USDT
    IERC20 public mga = IERC20(0xE36339cC77A7b155d7BC0543223D97831e5F60E9); // this is MGA
    */
    uint256 public deadlineDelta = 5 minutes;
    
    IConfigMining public configMining;
    
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    
    mapping(uint256 => poolStruct) public poolInfo;
    mapping(uint256 => mapping(address => userStruct)) public userInfo;
    
    uint256 public alreadWithdraw;
    uint256 public maxRewardAmount = 30000000*1e18;
    uint256 public basePerBlock = 1*1e14;
    uint256 public maxGain = 64;
    uint256 public userNeedReward; // this is add use used reward amount;
    
    //staking 
    uint256 public stakingMaxTime = 30 days;
    mapping(address => uint256 ) public userStakingAmount;
    mapping(address => uint256) public userStakingStartTime;
    
    bool public isNeedSwap;
    address[] public swapPath;
    
    
    mapping(address => uint256[]) public userPools;
    
    event AddPool(address user,uint256 _pid,uint256 _gameID,uint256 _perBlock,uint256 _startBlock,uint256 _endBlock);
    event Depost(address _user,uint256 _pid,uint256 _godTokenID,uint256[]  _batterTokens); 
    event Withdraw(address _user,uint256 _pid);
    event WithdrawReward(address _user,uint256 _pid,uint256 _reward);
    event Staking(address _user,uint256 _amount,uint256 _time);
    event WithdrawStaking(address _user,uint256 _amount,uint256 _time);
    
    event SetConfigMining(IConfigMining _configMining);
    event SetMaxStakingTime(uint256 _time);
    event EmergencyWithdrawE(uint256 _pid,address _user);
    
    struct userStruct{
        uint256 startBlock;
        uint256 witdrawBlock;
        uint256 godTokenID;
        uint256[] batterTokenIDList;
    }
    
    struct poolStruct{
        address user;
        uint256 gameID;
        uint256 perBlock;
        uint256 startBlock;
        uint256 endBlock;
        uint256 stopBlock;
        uint256 rewardAmount;
    }
    
    modifier onlyUserPool(uint256 _pid,address _user){
        require(poolInfo[_pid].user == _user,"only user pool");
        _;
    }
    
    constructor(IConfigMining _configMining,bool _isNeedSwap) {
        configMining = _configMining;
        
        if(_isNeedSwap){
            isNeedSwap = _isNeedSwap;
            swapPath.push(address(rewardToken));
            swapPath.push(address(USDT));
        }else{
            rewardToken = USDT;
        }
        
    }
    
    function setConfigMining(IConfigMining _configMining) public onlyManager{
        configMining = _configMining;
        
        emit SetConfigMining(_configMining);
    }
    
    function setMaxStakingTime(uint256 _time) public onlyManager{
        stakingMaxTime = _time;
        
        emit SetMaxStakingTime(_time);
    }
    
    function addPool(address _user,uint256 _pid,uint256 _gameID,uint256 _BlockLen) public onlyManager{
        require(_user != address(0),"_user is zeor ");
        require(configMining.isValidGameID(_gameID),"only config gameID");
        require(userNeedReward < maxRewardAmount,"only have reward");
        poolStruct storage pss = poolInfo[_pid];
        require(pss.user == address(0),"alread create ");
        
        poolInfo[_pid] = poolStruct({
            user:_user,
            gameID:_gameID,
            perBlock:basePerBlock,
            startBlock:block.number,
            endBlock:block.number+_BlockLen,
            stopBlock:0,
            rewardAmount:0
        });
        
        userPools[_user].push(_pid);
         
        emit AddPool(_user,_pid,_gameID,basePerBlock,block.number,block.number+_BlockLen);
    }
    
    function getRemainingReward() public view returns(uint256){
        return maxRewardAmount.sub(userNeedReward);
    }
    
    function depost(uint256 _pid,uint256 _godTokenID,uint256[] memory _batterTokens) public onlyUserPool(_pid,msg.sender){
        require(_batterTokens.length == 3,"_batterTokens not enough");
        poolStruct memory pss = poolInfo[_pid];
        require(block.number < pss.endBlock,"ended stake");
        
        userStruct storage uss = userInfo[_pid][msg.sender];
        
        uss.startBlock = block.number > pss.startBlock ? block.number:pss.startBlock;
        uss.witdrawBlock = uss.startBlock;
        uss.godTokenID = _godTokenID;
        IERC721 nftGod = IERC721(address(godNFT));
        if(_godTokenID > 0 ){
            nftGod.safeTransferFrom(msg.sender,address(this), _godTokenID);
        }
        
        uint256 len = _batterTokens.length;
        IERC721 nftbatter = IERC721(address(batterNFT));
        for(uint256 i=0; i<len ;i++){
            uss.batterTokenIDList.push(_batterTokens[i]);
            nftbatter.safeTransferFrom(msg.sender,address(this),_batterTokens[i]);
        }
        
        userNeedReward = userNeedReward.add(calcUserNeedReward(_pid,pss.gameID,msg.sender,uss.startBlock,pss.endBlock));
        
        emit Depost(msg.sender,_pid,_godTokenID,_batterTokens);
    }
    
    // this need  check maxReward 
    function calcUserNeedReward(
        uint256 _pid,
        uint256 _gameID,
        address _user,
        uint256 _startBlock,
        uint256 _endBlock) public view  returns(uint256 _needReward){
            uint256 blockLen = _endBlock.sub(_startBlock);
           
            userStruct memory uss = userInfo[_pid][_user];
            poolStruct memory pss = poolInfo[_pid];
        
            uint256 gain = (calcUserGodGain(uss.godTokenID)+1).mul(calcUserBattleGain(_pid,_gameID,_user));
            gain = gain > maxGain ? maxGain:gain;
            _needReward  = blockLen.mul(pss.perBlock).mul(gain);
            
             uint256 stakingGain = calcStakingGain(_user);
            if(stakingGain > 0){
                _needReward = _needReward.mul(stakingGain.add(100)).div(100);
            }
    }
    
    function withdraw(uint256 _pid) public{
        
        userStruct storage uss = userInfo[_pid][msg.sender];
        require(checkWithdraw(_pid,msg.sender),"checkWithdraw fail");
        
        withdrawReward(_pid);
        
        IERC721 nftGod = IERC721(address(godNFT));
        if(uss.godTokenID > 0){
            nftGod.safeTransferFrom(address(this), msg.sender, uss.godTokenID);
            uss.godTokenID = 0;
        }
        uint256 len = uss.batterTokenIDList.length;
        IERC721 nftbatter = IERC721(address(batterNFT));
        for(uint256 i=0; i<len ;i++){
            nftbatter.safeTransferFrom(address(this),msg.sender,uss.batterTokenIDList[i]);
        }
        if(len > 0){
            for(uint256 i=len-1; i>=0 ;i--){
                uss.batterTokenIDList.pop();
                if(i==0){
                    break;
                }
            }
        }
        uss.witdrawBlock = block.number;
        emit Withdraw(msg.sender,_pid);
        
    }
    
    function EmergencyWithdraw(uint256 _pid) public onlyUserPool(_pid,msg.sender){
        userStruct storage uss = userInfo[_pid][msg.sender];
        
        IERC721 nftGod = IERC721(address(godNFT));
        nftGod.safeTransferFrom(address(this), msg.sender, uss.godTokenID);
        uss.godTokenID = 0;
        uint256 len = uss.batterTokenIDList.length;
        IERC721 nftbatter = IERC721(address(batterNFT));
        for(uint256 i=0; i<len ;i++){
            nftbatter.safeTransferFrom(address(this),msg.sender,uss.batterTokenIDList[i]);
        }
        for(uint256 i=len-1; i<=0 ;i--){
            uss.batterTokenIDList.pop();
            if(i==0){
                break;
            }
            
        }
        uss.witdrawBlock = block.number;
        
        emit EmergencyWithdrawE(_pid,msg.sender);
    }
    
    function userPoolsLength(address _user) public view returns(uint256){
        return userPools[_user].length;
    }
    
    function checkWithdraw(uint256 _pid,address _user) public view returns(bool _canWithdraw){
        poolStruct memory pss = poolInfo[_pid];
        userStruct memory uss = userInfo[_pid][_user];
        
        
        if(block.number >= pss.endBlock && uss.batterTokenIDList.length>0){
            _canWithdraw = true;
        }
        
    }
    
    function staking(uint256 _amount) public{
        require(_amount >= 1000*1e18 && _amount <= 20000*1e18,"amount not right");
        uint256 stakingAmount = _amount.div(1000).mul(1000);
        
        mga.safeTransferFrom(msg.sender,address(this),stakingAmount);
        
        userStakingStartTime[msg.sender] = block.timestamp;
        userStakingAmount[msg.sender] = userStakingAmount[msg.sender].add(stakingAmount);
        
        emit Staking(msg.sender,stakingAmount,block.timestamp);
    }
    
    function withdrawStaking() public{
        require(userStakingAmount[msg.sender] > 0,"not staking amount");
        uint256 tiemLen = block.timestamp.sub(userStakingStartTime[msg.sender]);
        require(tiemLen >= stakingMaxTime, "The time limit has not expired");
        uint256 stakingAmount = userStakingAmount[msg.sender];
        userStakingStartTime[msg.sender] = 0;
        userStakingAmount[msg.sender] = 0;
        
        mga.safeTransfer(msg.sender,stakingAmount);
        
        emit WithdrawStaking(msg.sender,stakingAmount,block.timestamp);
        
    }
    
    
    function withdrawReward(uint256 _pid) public onlyUserPool(_pid,msg.sender) {
        address user = msg.sender;
        require(checkWithdraw(_pid,user),"checkWithdraw fail");
        poolStruct storage pss = poolInfo[_pid];
        userStruct storage uss = userInfo[_pid][user];
        uint256 _reward = pendingReward(_pid,pss.gameID,user);
        
        if(_reward > 0 ){
            
            uss.witdrawBlock = block.number;
            
            safeTransferReward(msg.sender,_reward);
            
            alreadWithdraw = alreadWithdraw.add(_reward);
            
            pss.rewardAmount = pss.rewardAmount.add(_reward);
        }
        
        emit WithdrawReward(msg.sender,_pid,_reward);
    }
    
    function safeTransferReward(address _user,uint256 _reward) internal {
        address contractAddress = address(this);
        uint256 curRewardBalance = rewardToken.balanceOf(contractAddress);
        require(curRewardBalance > _reward,"not enght");
        if(isNeedSwap){
            uint256 swapPathLen = swapPath.length;
            uint256 beforBalance = IERC20(swapPath[swapPathLen-1]).balanceOf(contractAddress);
            swap(rewardToken,_reward);
            uint256 afterBalance = IERC20(swapPath[swapPathLen-1]).balanceOf(contractAddress);
            require(afterBalance.sub(beforBalance) > 0,"swap balance is zeor");
            
            IERC20(swapPath[swapPathLen-1]).transfer(_user,afterBalance.sub(beforBalance));
            
        }else{
            rewardToken.transfer(_user,_reward);
        }
        
    }
    
    function swap(IERC20 _token,uint256 _amount) internal returns(uint256 amountOut){
        _token.approve(address(router), 0);
        _token.approve(address(router), _amount);

        uint256[] memory amounts = router.getAmountsOut(_amount, swapPath);
        amounts = router.swapExactTokensForTokens(
            _amount,
            amounts[amounts.length - 1],
            swapPath,
            address(this),
            block.timestamp.add(deadlineDelta)
        );
        
        amountOut = amounts[amounts.length - 1];
    }
    
    function pendingReward(uint256 _pid,uint256 _gameID,address _user) public view returns(uint256 _reward){
        userStruct memory uss = userInfo[_pid][_user];
        poolStruct memory pss = poolInfo[_pid];
        uint256 sBlock = uss.startBlock;
        uint256 tempReward;
        if(block.number > sBlock){
            uint256 eBlock = block.number >= pss.endBlock?  pss.endBlock :block.number;
            uint256 blockLen = eBlock.sub(sBlock);
            uint256 gain = (calcUserGodGain(uss.godTokenID)+1).mul(calcUserBattleGain(_pid,_gameID,_user));
            gain = gain > maxGain ? maxGain:gain;
            
            // need add new 
            
            tempReward  = blockLen.mul(pss.perBlock).mul(gain);
            
            uint256 stakingGain = calcStakingGain(_user);
            if(stakingGain > 0){
                tempReward = tempReward.mul(stakingGain.add(100)).div(100);
            }
             _reward = tempReward;
        }
        
    }
    
    function calcStakingGain(address _user) public view returns(uint256){
        return userStakingAmount[_user].mul(5).div(1000*1e18);
    }
    
    function calcUserBattleGain(uint256 _pid,uint256 _gameID,address _user) public view returns(uint256 ){
        uint256 x ;
       
        userStruct memory uss = userInfo[_pid][_user];
        uint256 len = uss.batterTokenIDList.length;
        for(uint256 i=0; i<len ;i++){
            x = x + calcBattleGain(_gameID,uss.batterTokenIDList[i]);
            if(x>=3){
                break;
            }
        }
        
        return 2**x;
    }
    
    // this returns is 2 ** n
    function calcBattleGain(uint256 _gameID,uint256 _tokenID) public view returns(uint256){
        // 1 Generation 6
    // 2 HP 8-0
    // 3 ATK 8-1
    // 4 SPD 8-2
    // 5 TEC 8-3
    // 6 DEF 8-4 
    // 7 SkillAmount 7 
    // 8 Skill 7
        IBattleNFT.CAttributes_S memory bss = batterNFT.cAttributes(_tokenID);
        uint256 len = configMining.getCheckListLength(_gameID);
        uint256 attributes;
        uint256 arvaule;
        for(uint256 i = 0; i<len ; i++){
            
            (attributes,arvaule) = configMining.getAttributesVaule(_gameID,i);
            
            if(attributes == 1){
              // Generation 
              if(bss.generation >= arvaule){
                  return 1;
              }
            }else if(attributes == 2){
               // 2 HP 8-0
               if(bss.battleAttrs[0] >= arvaule){
                  return 1;
               }
            }else if(attributes == 3){
                // 3 ATK 8-1
                if(bss.battleAttrs[1] >= arvaule){
                  return 1;
               }
            }else if(attributes == 4){
                // 4 SPD 8-2
                if(bss.battleAttrs[2] >= arvaule){
                  return 1;
                }
            }else if(attributes == 5){
                // 5 TEC 8-3
                if(bss.battleAttrs[3] >= arvaule){
                  return 1;
                }
            }else if(attributes == 6){
                // 6 DEF 8-4 
                if(bss.battleAttrs[4] >= arvaule){
                  return 1;
                }
            }else if(attributes == 7){
                // 7 SkillAmount 7
                if(bss.skillIds.length >= arvaule){
                  return 1;
                }
            }else if(attributes == 8){
                // 8 Skill 7
                for(uint256 j=0; j<bss.skillIds.length;j++ ){
                   if(bss.skillIds[j] == arvaule){
                       return 1;
                   } 
                }
                
            }
        }
        return 0;
    }
    function onERC721Received(address _operator, address _from,uint256 _tokenId,bytes calldata _data) external pure returns(bytes4){
        return MAGIC_ON_ERC721_RECEIVED;
    }
    
    // this returns 1,3 7
    function calcUserGodGain(uint256 _godTokenID) public view returns(uint256 godGain){
        IGodNFT.CAttributes_S memory css;
        css = godNFT.cAttributes(_godTokenID);
        if(css.rarityIdx == 2001){
            godGain = 1;
        }else if(css.rarityIdx == 2002){
            godGain = 2;
        }else if(css.rarityIdx == 2003){
            godGain = 7;
        }
    }
    
    
}