// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Verifications{
     constructor ()
    {
     LandInspectorId=msg.sender;
     landInspector("Mohsin",21,"LandInsepcctor");
    }

     struct LandInspectorDetails{
       address id;
       string name;
       uint age;
       string designation;
     }
     
     address public LandInspectorId;
     mapping(address=>LandInspectorDetails)public inspector;
     mapping(address=>bool)public sellerVerification;
     mapping(address=>bool)public sellerRejection;
     mapping(address=>bool)public buyerVerification;
     mapping(address=>bool)public buyerRejection;

     event VerifiedAddress (address _Id);
     event RejectedAddress(address _Id);

     modifier onlyLandInspector()
    {
     require (
         LandInspectorId==msg.sender,
         "You are Not LandInspector"
         );
     _;
    }
    
    modifier VerifyandRejectBuyer()
    {
      require(
          !buyerRejection[msg.sender],
          "You are Rejected Cannot Purchase "
          );
      require(
          buyerVerification[msg.sender]==true,
          "You are Not Verified"
          );
      _;
    }

     function landInspector(
     string memory name,
     uint age,
     string memory designation
     )
     internal
     {
     inspector[LandInspectorId]=LandInspectorDetails(
         msg.sender,name,age,designation
         );
     }

     function verifySeller(
     address SellerId
     )
     external
     onlyLandInspector()
     {
       sellerVerification[SellerId]=true;
       emit VerifiedAddress(SellerId);
     }

     function rejectSeller(
     address _sellerId
     )
     external
     onlyLandInspector()
      {
        sellerRejection[_sellerId]=true;
        emit RejectedAddress(_sellerId);
      }

     function verifyBuyer(
     address BuyerId
     )
     public
     onlyLandInspector()
     {
       buyerVerification[BuyerId]=true;
       emit VerifiedAddress (BuyerId);
     }

     function rejectBuyer(
     address BuyerId
     )
     public
     onlyLandInspector()
     {
       buyerRejection[BuyerId]=true;
       emit RejectedAddress(BuyerId);
     }
     }
 

  contract SellerandBuyerDetails is Verifications {

      struct SellerDetails{
       address id;
       string name;
       uint age;
       string city;
       uint cnic;
       string email;
     }

     struct BuyerDetails{
     address id;
     string name;
     uint age;
     string city;
     uint cnic;
     string email;
     }
   
     mapping (address=>SellerDetails)public SellerMapping;
     mapping (address=>BuyerDetails)public BuyerMapping;
     mapping (address=>bool)public IsSellerMapping;
     mapping(address=>bool)public IsBuyerMappping;

     event SellerRegistration(address _id);
     event BuyerRegistration(address _id);

      function registerSeller (
        string memory name,
        uint age,
        string memory city,
        uint cnic,
        string memory email
      )
      external
      {
        IsSellerMapping[msg.sender]=true;
        if (SellerMapping[msg.sender].id==msg.sender){
          SellerDetails storage seller =SellerMapping[msg.sender];
          seller.name=name;
          seller.age=age;
          seller.city=city;
          seller.cnic=cnic;
          seller.email=email;
        } else {
        SellerMapping[msg.sender]= SellerDetails(
        msg.sender,name,age,city,cnic,email
        );
        }
       }

       function registerBuyer (
        string memory name,
        uint age,
        string memory city,
        uint cnic,
        string memory email
       )
       external
       {
        IsBuyerMappping[msg.sender]=true;
        if (BuyerMapping[msg.sender].id==msg.sender){
         BuyerDetails storage buyer =BuyerMapping[msg.sender];
          buyer.name=name;
          buyer.age=age;
          buyer.city=city;
          buyer.cnic=cnic;
          buyer.email=email;
        }else{
         
          BuyerMapping[msg.sender]=BuyerDetails(
              msg.sender,name,age,city,cnic,email
              );
        }
      }
      
     function isSeller(
         address _Id
         )
         public view returns(bool)
         {
           if (IsSellerMapping[_Id]){
             return true;
         }else{
           return false;
         }
         }

     function isBuyer(
       address _Id
       )
       public view returns(bool)
         {
           if (IsBuyerMappping[_Id]){
             return true;
           }else{
             return false;
           }
           }
}

contract LandContract is SellerandBuyerDetails {

     enum landVerification {NotVerified,Verified}

     struct LandReg{
     landVerification verify;
      uint landid;
      string area;
      string city;
      string state;
      uint landprice;
      uint propertypid;
     } 

     mapping (uint=>LandReg)public land; 
     mapping (uint=>address)public landowner;

     event landdetails (
     address PreviousOwner,
     address newowner,
     uint LandId,
     uint amount);
     event AddedLand(
     uint _LandId,
     address owner
     );

     modifier buyerIsNotSeller()
    {
      require (
          SellerMapping[msg.sender].id!=msg.sender,
          "Seller Cant Purchase"
          );
      _;
    }
     modifier verifiedAndrejectCheck(){
     require(
         !sellerRejection[msg.sender],
         "You Are Rejected Cant Enter Detail"
         );
     require (
         sellerVerification[msg.sender]==true,
         "You are Not Verified"
         ); 
     _;
     }

     function enterLandDetails(
       uint landid,
       string memory area,
       string memory city,
       string memory state,
       uint landprice,
       uint propertypid
     )
     external 
     verifiedAndrejectCheck()
     { 
      land[landid]=LandReg(
      landVerification.NotVerified,landid,
      area,city,state,landprice,propertypid
      );
      landowner[landid]=msg.sender;
      emit AddedLand(
         landid,landowner[landid]
          );
     }
     
     function verifyLand(uint _LandId)external onlyLandInspector{
       land[_LandId].verify=landVerification.Verified;
     }

     function purchaseLand(
     uint _LandId,uint _amount
     )
     external payable 
     VerifyandRejectBuyer() buyerIsNotSeller()
     {
       address previousOwner= landowner[_LandId];
       address newOwner=msg.sender;
       require(
           land[_LandId].verify==landVerification.Verified,
           "Land is Not Verified"
           );
       require(
           land[_LandId].landprice == _amount,
           "Please Pay full Payment"
           );
       require (
           msg.value==_amount,
           "Please EnterExactAmount"
           );
       landowner[_LandId]=newOwner;
       payable (previousOwner).transfer(_amount);
        emit landdetails(
        previousOwner,msg.sender,
        _LandId,_amount
        );
       }

     function transferLand(uint _LandId, address _NewOwner)external
      {
       require(msg.sender==landowner[_LandId],
       "You are Not A Owner"
       );
       landowner[_LandId]=_NewOwner;
      }
          
     function getLandDetails(uint LandId)public view returns (
          uint256,
          string memory,
          string memory,
          string memory,
          uint256,
          uint256
         )
         {   
        return (
             land[LandId].landid,
             land[LandId].area,
             land[LandId].city,
             land[LandId].state,
             land[LandId].landprice,
             land[LandId].propertypid
            );
           
        }

        function isLandVerified(
        uint LandId)
        public view returns (bool)
        {
          if((land[LandId].verify==landVerification.Verified))
          {
            return true;
          }else{
            return false;
          }
        }

        function checkLandOwner(
          uint landId
          )
          public view returns (address)
          {
            return landowner[landId];
          }
           
         function CheckLandInspector()
          public view returns (address)
           {
             return LandInspectorId;
           }

         function getLandCity(
           uint city
          )public view returns(string memory)
         {
           return land[city].city;
         }

         function getLandPrice(
           uint landprice
           )public view returns (uint)
         {
           return land[landprice].landprice;
         }

         function getLandArea(uint landarea)
         public view returns (string memory)
         {
           return land[landarea].area;
         }
           
       }

