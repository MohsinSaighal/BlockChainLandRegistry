// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Verifications {
    struct LandInspectorDetails {
        address id;
        string name;
        uint256 age;
        string designation;
    }

    address internal LandInspectorId;
    mapping(address => LandInspectorDetails) internal inspector;
    mapping(address => bool) internal sellerVerification;
    mapping(address => bool) internal sellerRejection;
    mapping(address => bool) internal buyerVerification;
    mapping(address => bool) internal buyerRejection;

    event VerifiedAddress(address _Id);
    event RejectedAddress(address _Id);

    constructor() {
        LandInspectorId = msg.sender;
        landInspector("Mohsin", 21, "LandInsepcctor");
    }

    modifier onlyLandInspector() {
        require(LandInspectorId == msg.sender, "You are Not LandInspector");
        _;
    }

    modifier VerifyandRejectBuyer() {
        require(
            !buyerRejection[msg.sender],
            "You are Rejected Cannot Purchase "
        );
        require(buyerVerification[msg.sender], "You are Not Verified");
        _;
    }

    function landInspector(
        string memory name,
        uint256 age,
        string memory designation
    ) internal {
        inspector[LandInspectorId] = LandInspectorDetails(
            msg.sender,
            name,
            age,
            designation
        );
    }

    function verifySeller(address SellerId) external onlyLandInspector {
        sellerVerification[SellerId] = true;
        emit VerifiedAddress(SellerId);
    }

    function rejectSeller(address _sellerId) external onlyLandInspector {
        sellerRejection[_sellerId] = true;
        emit RejectedAddress(_sellerId);
    }

    function verifyBuyer(address BuyerId) public onlyLandInspector {
        buyerVerification[BuyerId] = true;
        emit VerifiedAddress(BuyerId);
    }

    function rejectBuyer(address BuyerId) public onlyLandInspector {
        buyerRejection[BuyerId] = true;
        emit RejectedAddress(BuyerId);
    }
}

contract SellerandBuyerDetails is Verifications {
    struct SellerDetails {
        address id;
        string name;
        uint256 age;
        string city;
        uint256 cnic;
        string email;
    }

    struct BuyerDetails {
        address id;
        string name;
        uint256 age;
        string city;
        uint256 cnic;
        string email;
    }

    mapping(address => SellerDetails) internal SellerMapping;
    mapping(address => BuyerDetails) internal BuyerMapping;
    mapping(address => bool) internal IsSellerMapping;
    mapping(address => bool) internal IsBuyerMappping;

    event SellerRegistration(address _id);
    event BuyerRegistration(address _id);

    function registerSeller(
        string memory name,
        uint256 age,
        string memory city,
        uint256 cnic,
        string memory email
    ) external {
        IsSellerMapping[msg.sender];
        if (SellerMapping[msg.sender].id == msg.sender) {
            SellerDetails storage seller = SellerMapping[msg.sender];
            seller.name = name;
            seller.age = age;
            seller.city = city;
            seller.cnic = cnic;
            seller.email = email;
        } else {
            SellerMapping[msg.sender] = SellerDetails(
                msg.sender,
                name,
                age,
                city,
                cnic,
                email
            );
        }
    }

    function registerBuyer(
        string memory name,
        uint256 age,
        string memory city,
        uint256 cnic,
        string memory email
    ) external {
        IsBuyerMappping[msg.sender];
        if (BuyerMapping[msg.sender].id == msg.sender) {
            BuyerDetails storage buyer = BuyerMapping[msg.sender];
            buyer.name = name;
            buyer.age = age;
            buyer.city = city;
            buyer.cnic = cnic;
            buyer.email = email;
        } else {
            BuyerMapping[msg.sender] = BuyerDetails(
                msg.sender,
                name,
                age,
                city,
                cnic,
                email
            );
        }
    }

    function isSeller(address _Id) public view returns (bool) {
        if (IsSellerMapping[_Id]) {
            return true;
        } else {
            return false;
        }
    }

    function isBuyer(address _Id) public view returns (bool) {
        if (IsBuyerMappping[_Id]) {
            return true;
        } else {
            return false;
        }
    }
}

contract LandContract is SellerandBuyerDetails {
    enum landVerification {
        NotVerified,
        Verified
    }

    struct LandReg {
        landVerification verify;
        uint256 landid;
        string area;
        string city;
        string state;
        uint256 landprice;
        uint256 propertypid;
    }

    mapping(uint256 => LandReg) internal land;
    mapping(uint256 => address) internal landowner;

    event landdetails(
        address PreviousOwner,
        address newowner,
        uint256 LandId,
        uint256 amount
    );
    event AddedLand(uint256 _LandId, address owner);

    modifier buyerIsNotSeller() {
        require(
            SellerMapping[msg.sender].id != msg.sender,
            "This Account is Registered As Seller "
        );
        _;
    }
    modifier verifiedAndrejectCheck() {
        require(
            !sellerRejection[msg.sender],
            "You Cant Enter Landdetails because You are Rejected"
        );
        require(sellerVerification[msg.sender], "You are Not Verified");
        _;
    }

    function enterLandDetails(
        uint256 landid,
        string memory area,
        string memory city,
        string memory state,
        uint256 landprice,
        uint256 propertypid
    ) external verifiedAndrejectCheck {
        land[landid] = LandReg(
            landVerification.NotVerified,
            landid,
            area,
            city,
            state,
            landprice,
            propertypid
        );
        landowner[landid] = msg.sender;
        emit AddedLand(landid, landowner[landid]);
    }

    function verifyLand(uint256 _LandId) external onlyLandInspector {
        land[_LandId].verify = landVerification.Verified;
    }

    function purchaseLand(uint256 _LandId, uint256 _amount)
        external
        payable
        VerifyandRejectBuyer
        buyerIsNotSeller
    {
        address previousOwner = landowner[_LandId];
        address newOwner = msg.sender;
        require(
            land[_LandId].verify == landVerification.Verified,
            "Land is Not Verified"
        );
        require(land[_LandId].landprice == _amount, "Please Pay full Payment");
        require(msg.value == _amount, "Please EnterExactAmount");

        landowner[_LandId] = newOwner;
        payable(previousOwner).transfer(_amount);
        emit landdetails(previousOwner, msg.sender, _LandId, _amount);
    }

    function transferLand(uint256 _LandId, address _NewOwner) external {
        require(msg.sender == landowner[_LandId], "You are Not A Owner");
        landowner[_LandId] = _NewOwner;
    }

    function getLandDetails(uint256 LandId)
        public
        view
        returns (
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

    function isLandVerified(uint256 LandId) public view returns (bool) {
        if ((land[LandId].verify == landVerification.Verified)) {
            return true;
        } else {
            return false;
        }
    }

    function checkLandOwner(uint256 landId) public view returns (address) {
        return landowner[landId];
    }

    function CheckLandInspector() public view returns (address) {
        return LandInspectorId;
    }

    function getLandCity(uint256 city) public view returns (string memory) {
        return land[city].city;
    }

    function getLandPrice(uint256 landprice) public view returns (uint256) {
        return land[landprice].landprice;
    }

    function getLandArea(uint256 landarea) public view returns (string memory) {
        return land[landarea].area;
    }
}
