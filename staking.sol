//SPDX-License-Identifier:MIT
pragma solidity ^0.8.15;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Staking {
//token sepordeh gozari.
IERC20 public  stakingToken;

//token soud dehi.  
IERC20 public  rewardToken; 

//nerkhe soud dehi.
uint public constant rewardRate = 3*10**13;

//
uint public lastUpdateTime;

// soud e har token.
uint public rewardPerTokenStored;

//tedade kole token haye sepordeh shodeh dar system.
uint private totalStakedTokens;

//tedad e sepordeh gozaran.
uint public investorsNumber;

//har account che tedad token sarmayeh gozari(sepordeh) kardeh ast.
mapping(address => uint) private balances;

//soude har token e sarmayeh gozar.
mapping(address=>uint) rewardPerInvestorToken;

//soud e pardakht shodeh(tedad token pardakht shodeh) be har  sarmayeh gozar.
mapping(address=>uint) rewardPaidToInvestor;

// soud e pardakt nashodeh har sarmayeh gozar.
mapping(address=>uint) unPaidReward;

event stakeToken(address,uint);
event withrawToken(address,uint);
event getReward(address,uint);


constructor(address stakingTokenAddress,address rewardTokenAddress)
{
   stakingToken=IERC20(stakingTokenAddress);
   rewardToken=IERC20(rewardTokenAddress);
}

modifier updateReward(address account)
{

  //soud yek token.
  rewardPerTokenStored=tokenRewardComputing();
  
  //
  lastUpdateTime=block.timestamp;

  //kole reward pardakht nashodeh az lastUpdateTime ta in lahzeh.
  unPaidReward[account] = totalUnpaidInterest(account);

  //reward pardakht shodeh be sepordeh gozar ta in lahzaeh.
  rewardPerInvestorToken[account] = rewardPerTokenStored;
  _;
}


//sepordeh(sarmayeh gozari).
//amount tedad tokeni  ast ke shakhs ghasd darad stake(sepordeh konad).
function stake(uint amount) public updateReward(msg.sender)
{
  //rewardPerTokenStored=tokenRewardComputing(); 
  if(balances[msg.sender] == 0)investorsNumber++;
  
  //update kole token haye stake shodeh.
  totalStakedTokens += amount;
   
  //update token hayei ke callerfunction stake kardeh ast.
   balances[msg.sender]+=amount;

   //enteghal token tavasote contractStaking az account shakhs e sarmayeh gozar(callerfunction,Investor) be account contractStaking.
   stakingToken.transferFrom(msg.sender,address(this),amount);
   
   emit stakeToken(msg.sender,amount);
}

//mohasebeh kol e soude sepordeh gozar ba tavajoh be soudeh yek token va tedad kole token haei ke stake kardeh ast. 
function totalUnpaidInterest(address account) public view returns(uint) 
{
    return ( unPaidReward[account] + (balances[account]*(tokenRewardComputing()-rewardPerInvestorToken[account]))/1e18 );
}

//mohasebeh soud(reward) yek token.
function tokenRewardComputing() public view returns(uint)
{
  if(totalStakedTokens==0) return 0;
  return (rewardPerTokenStored+((block.timestamp-lastUpdateTime)*(rewardRate)*1e18))/totalStakedTokens;
    
}

modifier rewardBalanceCheck(address account)
{
    require(unPaidReward[account]>0," You have not reward.");
    _;
}

//bardasht soud(reward).
function withdrawReward()public  rewardBalanceCheck(msg.sender) updateReward(msg.sender)
{
  /*baresi inke aya shakhs soudi baraye bardasht darad ya kheyr
   be komake rewardBalanceCheck().*/
    
  uint reward=unPaidReward[msg.sender];
   
  //ba bardasht e kole reward ghatan soudi baraye pardakht baghi nemimanad.
  unPaidReward[msg.sender]=0;

  // bardashte  soud .
  rewardToken.transfer(msg.sender,reward);

  /*ba enteghal rewardToken be sarmayeh gozar(Investor) 
  ghatan soudeh pardakht shodeh be sarmayeh gozar 
  taghir khahad kard.*/
  rewardPaidToInvestor[msg.sender]+=reward;
    
  emit getReward(msg.sender,reward);
}

modifier stakingTokenBalanceCheck(address account,uint amount_)
{
    require(balances[account]>=amount_,"you haven't enough staked tokens!");
    _;
}
//bardasht sarmayeh.
function withdrawalStake(uint amount) public stakingTokenBalanceCheck(msg.sender,amount) updateReward(msg.sender)
{
   //meghdar madenazar baraye bardasht bayad baresi inkeh aya  sepordeh shakhs(stakingToken) kafi ast ya kheyr.
   //kahesh kol stakeToken haye sepordeh shodeh dar natijeh bardasht sarmayeh.
   totalStakedTokens-=amount;
   
   //kahesh sepordeh dar natijeh bardasht.
   balances[msg.sender]-=amount;

   //if shakhs kole sarmaye khod ra kharej konad(amount kole tedad tokeni bashad ke shakhs sarmaye gozari kardeh.)
   if(balances[msg.sender]==0)investorsNumber--;
   
   stakingToken.transfer(msg.sender,amount);

   emit withrawToken(msg.sender,amount);
}

//bardashte soud va sepordeh(etmam gharardad).
function depositWithdrawal() public 
{
   //bardasht sepordeh.
   withdrawalStake(balances[msg.sender]); 
   
   //bardasht e soud.
   withdrawReward();
   
}

//address stake_contract.
function stakingContractAddressShow() public view returns(address)
{
   return address(this);
}

//kol token haei ke afrad stake kardand.
function totalStakingTokenShow() public view returns(uint)
{
   return totalStakedTokens;
}

//kol token haei ke yek shakhs stake kardeh ast.
function tokenShow(address account) public view returns(uint)
{
  return balances[account];
}

}

//==========================

//=========================

contract StakingToken is ERC20 {
    
    //Token(600,"Staking Token","STK",18)
    constructor() ERC20("Staking Token","STK") 
    {
      _mint(msg.sender,6000000*10**decimals());
    }
}

//===============

contract RewardToken is ERC20 {
    constructor() ERC20("Reward Token","RTK") 
    {
      _mint(msg.sender,4000000*10**decimals());
    }
}

