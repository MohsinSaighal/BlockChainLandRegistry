// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Verifications{
     constructor ()
    {
     LandInspectorId=msg.sender;
     LandInspector("Mohsin",21,"LandInsepcctor");
    }

     struct LandInspectorDetails
    {
       address Id;
       string _Name;
       uint _Age;
       string Designation;
     }
     
     address public LandInspectorId;
     mapping(address=>LandInspectorDetails)public Inspector;
     mapping (address=>bool)public SellerVerification;
     mapping (address=>bool)public SellerRejection;
     mapping (address=>bool)public BuyerVerification;
     mapping(address=>bool)public BuyerRejection;

     modifier onlyLandInspector()
    {
     require (LandInspectorId==msg.sender,"You are Not LandInspector");
     _;
    }

    modifier BuyerIsNotSeller()
    {
      require (!SellerVerification[msg.sender],"Seller Cant Purchase");
      _;
    }
    
    modifier VerifyandRejectBuyer()
    {
      require(!BuyerRejection[msg.sender],"You are Rejected Cannot Purchase ");
      require(BuyerVerification[msg.sender]==true,"You are Not Verified");
      _;
    }

     function LandInspector(
     string memory _Name,uint _Age,string memory Designation
     )internal
     {
     Inspector[LandInspectorId]=LandInspectorDetails(msg.sender,_Name,_Age,Designation);
     }

     function VerifySeller(
     address sellerId
     )onlyLandInspector()external
     {
       SellerVerification[sellerId]=true;
     }

     function RejectSeller(
     address _sellerId
     )onlyLandInspector() external
      {
        SellerRejection[_sellerId]=true;
      }

     function VerifyBuyer(
     address BuyerId
     )onlyLandInspector()public
     {
       BuyerVerification[BuyerId]=true;
     }

     function RejectBuyer(address BuyerId)onlyLandInspector()public
     {
       BuyerRejection[BuyerId]=true;
     }
     }
 
  contract SellerandBuyerDetails is Verifications {
      struct SellerDetails
     {
       address Id;
       string _Name;
       uint _Age;
       string _City;
       uint _CNIC;
       string _Email;

     }
     struct BuyerDetails
    {
     address Id;
     string _Name;
     uint _Age;
     string _City;
     uint _CNIC;
     string _Email;
     }
   
     mapping (address=>SellerDetails)public SellerMapping;
     mapping (address=>BuyerDetails)public BuyerMapping;
     mapping (address=>bool)public IsSellerMapping;
     mapping(address=>bool)public IsBuyerMappping;

      event SellerRegistration (address _id);
      event BuyerRegistration(address _id);

      function updateSellerInfo (
        string memory _Name,uint _Age,string memory _City,uint _CNIC,string memory _Email
      )external
      {
        IsSellerMapping[msg.sender]=true;
        if (IsSellerMapping[msg.sender]){
          SellerMapping[msg.sender]= SellerDetails(msg.sender,_Name,_Age,_City,_CNIC,_Email);
        }else {
          SellerDetails storage seller =SellerMapping[msg.sender];
          seller._Name=_Name;
          seller._Age=_Age;
          seller._City=_City;
          seller._CNIC=_CNIC;
          seller._Email=_Email;
        }
       }

       function updateBuyerInfo (
        string memory _Name,uint _Age,string memory _City,uint _CNIC,string memory _Email
       )external
       {
        IsBuyerMappping[msg.sender]=true;
        if (IsBuyerMappping[msg.sender]){
          BuyerMapping[msg.sender]= BuyerDetails(msg.sender,_Name,_Age,_City,_CNIC,_Email);
        }else {
          BuyerDetails storage buyer =BuyerMapping[msg.sender];
          buyer._Name=_Name;
          buyer._Age=_Age;
          buyer._City=_City;
          buyer._CNIC=_CNIC;
          buyer._Email=_Email;
        }
      }
      

     function IsSeller(
         address _Id
         )public view returns(bool)
         {
           if (IsSellerMapping[_Id]){
             return true;
         }
         }

     function IsBuyer(address _Id)public view returns(bool)
         {
           if (IsBuyerMappping[_Id]){
             return true;
           }
           }
}

contract LandContract is SellerandBuyerDetails {

     enum Verification {NotVerified,Verified}
     struct LandReg
     {
     Verification verify;
      string _Area;
      string _City;
      string _State;
      uint _LandPrice;
      uint _PropertyPID;
     } 

     mapping (uint=>LandReg)public Land; 
     mapping (uint=>address)public LandOwner;
     event landOwner (address Owner,uint LandId);

     modifier VerifiedAndRejectCheck(){
     require(!SellerRejection[msg.sender],"You Are Rejected Cant Enter Detail");
     require (SellerVerification[msg.sender]==true,"You are Not Verified"); 
     _;
     }

     function EnterLandDetails(
     uint _LandId,string memory _Area,string memory _City,string memory _State,uint _LandPrice,uint _PropertyPID
     )external VerifiedAndRejectCheck()
     { 

      Land[_LandId]=LandReg(Verification.NotVerified,_Area,_City,_State,_LandPrice,_PropertyPID);
      LandOwner[_LandId]=msg.sender;
      emit landOwner(msg.sender,_LandId);
      
     }
     
     function VerifyLand(
     uint _LandId
     )external  onlyLandInspector
     {
       Land[_LandId].verify=Verification.Verified;

     }

     function PurchaseLand(
     uint _LandId,uint _amount
     )external payable VerifyandRejectBuyer
     {
       address  PreviousOwner= LandOwner[_LandId];
       address newOwner=msg.sender;
       require(Land[_LandId].verify==Verification.Verified,"Land is Not Verified");
       require(Land[_LandId]._LandPrice == _amount,"Please Pay full Payment");
       require (msg.value==_amount,"Please EnterExactAmount");
       LandOwner[_LandId]=newOwner;
       payable (PreviousOwner).transfer(_amount);
       }

     function transferLand(
     uint _LandId,address _NewOwner
     )external
      {
       require(msg.sender==LandOwner[_LandId],"You are Not A Owner");
       LandOwner[_LandId]=_NewOwner;

      }
          
     function GetLandDetails(
          uint LandId
         )public view returns (
          uint256,string memory,string memory,string memory,uint256,uint256
         )
         {
           
        return (
         Land[LandId]._LandPrice,
             Land[LandId]._Area,
             Land[LandId]._City,
             Land[LandId]._State,
             Land[LandId]._LandPrice,
             Land[LandId]._PropertyPID
            );
           
        }

        function CheckLandVerification(
          uint LandId
        )public view returns (bool)
        {
          if((Land[LandId].verify==Verification.Verified))
          {
            return true;
          }
        }

        function CheckLandOwner(
          uint _LandId
          )public view returns (address)
          {
            return LandOwner[_LandId];
          }
           
         function CheckLandInspector(

         )public  view returns (
           address
           )
           {
             return LandInspectorId;
           }

         function GetLandCity(
           uint city
          )public view returns(string memory)
         {
           return Land[city]._City;
         }

         function GetLandPrice(
           uint LandPrice
           )public view returns (uint)
         {
           return Land[LandPrice]._LandPrice;
         }

         function GetLandArea(uint LandArea)public view returns (string memory)
         {
           return Land[LandArea]._Area;
         }
           
       }
