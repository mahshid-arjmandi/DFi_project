//SPDX-License-Identifier:MIT
pragma solidity ^0.8.15;

contract Token
{
  //mojodi avalieh token.
  uint private initialSupply;

  //tedad e kole token haye shabakeh.
  uint private totalSupply;

  //address maleke token.  
  address private owner; 

  // tokenName
  string public name;

  //tokenSymbol.
  string public symbol;

  uint8 public decimals;

  //tedad token mojodi  har account.
  mapping (address=>uint) public balances;
 
 //meghdar token e ghabele bardasht az accounti ke token darad.
 mapping(address=>mapping(address=>uint)) public allowances;

 //enteghal token az yek account be account digar.
 event  Transfer(address indexed source,address indexed destination,uint amount);
 //tedad tokeni ke nafar sevom az yek account mitavanad kharj konad.
 event Approval(address indexed tokenOwner,address indexed spender,uint amount);

 constructor(uint initialSupply_,string memory name_,string memory symbol_,uint8 decimals_)
 {
  
   owner=msg.sender;
   initialSupply=initialSupply_;
   decimals=decimals_;
   name=name_;
   symbol=symbol_;

   //enteghal token az address(0) be maleketoken(owner).
   mint(initialSupply*(10**decimals));
 }

 modifier ownerCheck()
 {
     require(msg.sender==owner,"only owner can mint.");
     _;
 }

 //enteghal token az address(0) be maleketoken(owner).
 function mint(uint amount) public ownerCheck() 
 {
      //mint ra faght owner mitavanad anjam dahad.
      //enteghal token az address(0) be tokenOwnerAddress.
      balances[owner]+=amount;
      totalSupply+=amount;
      
      emit Transfer(address(0),owner,amount);
 }
 
 //enteghal token be address(0).
 function burn(uint amount) public ownerCheck()
 {
  //burn ra faght owner mitavanad anjam dahad. 
  balances[owner] -= amount;
  totalSupply -= amount;
  emit Transfer(msg.sender, address(0), amount);
  }


 //check kardan mojodi callerFunction be komake balanceCheck.
 modifier balanceCheck(address destination_,uint amount_)
 {
   
   require(balances[msg.sender]>=amount_,"Not enough balance.");
   _;
 }

 //enteghal token az yek account(callerFunction) be account digar.
 function transfer(address destination,uint amount) public balanceCheck(destination,amount) returns(bool)
 {
    //check kardan mojodi callerFunction be komake balanceCheck.
    
    //bardashte token az callerfunction.
    balances[msg.sender]-=amount;

    //enteghale token be account madenazar(destination).
    balances[destination]+=amount;
    emit Transfer(msg.sender,destination,amount);
    return true;
 }

//be spender ejazeh dadeh mishavad be andazeh amount az yek account token bardarad.
function approve(address spender,uint amount) public returns(bool)
{
  allowances[msg.sender][spender]=amount;

  emit Approval(msg.sender,spender,amount);
  return true;
}


function transferFrom(address source,address destination,uint amount) public returns(bool)
{
  //moshakhas kardane tedad tokeni ke spender(callerFunction) mitavanad az hessab source enteghal dahad.
  uint allowance_=allowances[source][msg.sender];
  
  /*moghayeseh  tedad tokeni(allowance_) ke spender be onvan nafar sevom mojaz ast az source   be destination 
   enteghal dahad  ba tedad tokeni(amount) ke baraye ersal made nazar gharar darad.*/

  require(allowance_>=amount, "The transaction transferFrom was not completed because insufficient allowance!");
  
  //barresi mojoudi source.
  require(balances[source]>=amount, "The transaction transferFrom was not completed because Not enough balance!");
  
  //bardasht tedadi token(be andazeh amount) az source.  
  balances[source] -=amount;    

  //enteghal token be hesabe destination.
  balances[destination]+=amount;

  //update meghdari ke spender mojaz ast az source bardasht konad. 
  allowances[source][msg.sender]-=amount;

  emit Transfer(msg.sender, destination,amount);
  return true;
}

//namayesh mojodi  account madenazar.
function balanceOf(address account) public view returns(uint) 
{
  return balances[account];
}

/*namayeshe tedad tokeni ke shakhs sevom(spender) 
mitavanad az hesab(sourceAddress) bardasht konad.*/
function allowance(address sourceAddress, address spender) public view returns(uint)
 {
  return allowances[sourceAddress][spender];
 }

 //namayesh kole token e mojoud dar shabakeh.
function getTotalSupply()public view returns(uint)
{
  return totalSupply;
}
}


