//SPDX-License-Identifier:MIT
pragma solidity ^0.8.15;

interface IAuction
{
    function proposalPrice(uint proposedPrice) external;
}

contract Auction
{
    uint basePrice;
    address public contractAddress;
    address public ownerAddress;
    uint    public contractBalance;
    uint [] proposalPriceList;//listi az gheymat haye pishnahadi.
    address [] recommendersAddresses;//listi az address kasani ke gheymat e pishnahadi un ha pazirofteh shodeh ast. 
    mapping (address=>uint) recommenderInfo;//etelate kasi ke gheymat pishnahadi un ha pazirofteh shodeh ast:recommenderInfo[msg.sender]=amount.
    uint totalProposedPrice;//kole meghdari ke  tavasote yek sherkat konandeh pishnahd dadeh shodeh ast. 
    uint [] totalProposalPriceList;
    mapping(address =>uint) recommenderInfoTotalProposalPrice;//uint=>totalProposalPriceList

    event Recived(address);
constructor() payable
{
    
    ownerAddress=msg.sender;
   contractAddress=payable(address(this)); 
   contractBalance=address(this).balance;  
}

   receive() external payable 
   {
        emit Recived(msg.sender);        
   }


    function determinationBasePrice(uint basePrice_) public  onlyOwner
    {
         basePrice=basePrice_;
    }

    /*baraye inkeh shakhsi bihoudeh pishnahad gheymat nadahad
     ebteda tedei ether be smart_contract enteghal midahad
    dar payan mozayedeh agar pishnahad pazirofteh nashod haman mablagh baz migardad.*/

    modifier balanceCheck(uint proposedPrice_)
    {
       //gheymate pishnahadi bayad az gheymate maddenazar modir mozayedeh bishtar bashad.
        require(proposedPrice_ >=basePrice,"The proposed price is not acceptable because the proposed price is lower than the base price.");
       
       
       //barresi mojodi shakhs e sherkat konandeh.
       require(((msg.sender).balance)>=(proposedPrice_),"!!! Your account balance is insufficient."); 
       _;
    } 
    //ersal pishnahad gheymat.
    //gheymat e madenazar dar sourati ghabel e ghaboul ast ke .
    function proposalPrice(uint proposedPrice) external  balanceCheck(proposedPrice)
    {
        /* barresi inke aya shakhs mojoudi kafi darad ya kheyr
         be komak e modifier balancecheck.*/
          
        /*enteghal e nesfe gheymat e pishnahadi be smartContract
         jahat e etminan az inke fard bihoudeh pishnahad gheymat nadahad.
         dar payan mozayedeh agar pishnahad pazirofteh nashod
         haman mablagh baz migardad.*/
        payable(address(this)).transfer(proposedPrice/2);
        
        /*be vasileh totalProposedPrice  moshakhas mishavad be shekast khordeh ha 
        dar mozayedeh che mablaghi bayad bargasht dadeh shavad.*/
        totalProposedPrice+=proposedPrice;
        totalProposalPriceList.push(totalProposedPrice); 
        recommenderInfoTotalProposalPrice[msg.sender]=totalProposedPrice;
        
        //ezafeh kardan pishnahad pazirofteh shodeh be list gheymat haye pishnahadi.
        proposalPriceList.push(proposedPrice);
        
        /*ezafeh kardan address pishnahad dahandeh(pishnahad pazirofteh shodeh) 
          be list address  haye pishnahadi.*/
        recommendersAddresses.push(msg.sender);   

        //ezafeh kardan gheymate pishnahadi jadid.
        recommenderInfo[msg.sender]=proposedPrice;
    }

    
     function recommendershAddresses()public view returns(address)
     {
         return recommendersAddresses[0];
     }
     //namayesh  mojoudi contract.
    function getContractBalance() public view returns(uint)
    {
        return address(this).balance;
    }

    //Taeein barandeh.
    address public winnerAddress;//address barandeh.
    function winner() public 
    {
       uint highestProposalPrice=proposalPriceList[0];
       
       //moghayeseh gheymat haye pazirofteh shodeh va taein balatarin gheymat.
       for(uint8 index=0;index<recommendersAddresses.length;index++)
       {
            //ifgheymati ke shakhse dovom pishnahad dadeh ast(proposalPriceList[index]>highestProposalPrice)bashad.
            if((recommenderInfo[recommendersAddresses[index]])>highestProposalPrice)
            {
                //
                highestProposalPrice=recommenderInfo[recommendersAddresses[index]];
                
                //moshakhas kardan address barandeh (shakhsi ke bishtarin gheymat ra pishnahd dad).
                winnerAddress=recommendersAddresses[index];
            }

            //if 2 fard pishnahad gheymat yeksan eraeh dadnd be sourate random yeki entekhab shavad.
            else if((recommenderInfo[recommendersAddresses[index]])==highestProposalPrice)
            {
              uint  rand=uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty)));
              rand=rand%(recommendersAddresses.length);
              winnerAddress=recommendersAddresses[rand];
            }
            else
            {
             continue;
            }
       }

    }

  //owner contract ra be onvan modir mozayedeh dar nazar migirim.
  modifier onlyOwner()
  {
      require(msg.sender==ownerAddress,"Only the auction manager is allowed to return the amounts to the accounts of individuals.");
      _;
  }

    //bazgasht mablagh be shekast khordeh ha dar mozayedeh.
    function refund() public onlyOwner
    {
           //faghat modeir mozayedeh ghader be bargasht dadan mabalegh mibashad.
           uint returnValue;//meghdari ke bayad be shekast khordeh ha baz gardad.
           for(uint index=0;index<recommendersAddresses.length;index++)
           {
               if(recommendersAddresses[index]!=winnerAddress)
               {
                 //mohasebeh  mablaghi ke bayad be shakhs shekast khordeh bazgardad.  
                 returnValue=(recommenderInfoTotalProposalPrice[recommendersAddresses[index]])/2;
                 
                 //enteghal nesfe mablaghi ke har shakhs pishnahad dadeh ast.
                 (bool sent,)=recommendersAddresses[index].call{value:returnValue}("");
                  require(sent==true,"The transfer was not successful.");
               }
           }
    }


 modifier addresscheck(address recommenderAddress_)
    {
       bool result;
       for(uint8 i=0;i<recommendersAddresses.length;i++)
       {
           if(recommendersAddresses[i]==recommenderAddress_)
           {
               result=true;
               break;
           } 
       }
       require(result==true,"This person's information is not registered because her offer was not accepted.");
       _;
    }
     
    function showTotalProposedPriceByPerson(address recommenderAddress) public view addresscheck(recommenderAddress) returns(uint) 
    {
       /*baraesi inke ayay address madenazar 
       pishnahadash sabt shodeh ast ya kheyr 
       be komak e modifier addresscheck().*/ 
       return recommenderInfoTotalProposalPrice[recommenderAddress];
    }

    

}


//===============
contract personalWallet
{

address public ownerAddress;//address deploye konandeh contract dar blockchain.
address public contractAddress;
constructor() payable
{
    ownerAddress=msg.sender;
    contractAddress=address(this);
}

function callProposalPrice(address payable auctionContract_,uint proposedPrice_) public 
{
     IAuction(auctionContract_).proposalPrice(proposedPrice_);
}

function getBalance() public view returns(uint)
{
    return (msg.sender).balance;
}

}