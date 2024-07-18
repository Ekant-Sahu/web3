// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VehicleInsurance {
    struct Insurance {
        uint256 id;
        address owner;
        string vehicleDetails;
        uint256 premium;
        uint256 insuredAmount;
        bool isClaimed;
    }

    uint256 public insuranceCount;
    uint256 public riskPool;
    mapping(uint256 => Insurance) public insurances;
    mapping(address => uint256) public balances;

    event NewInsurance(
        uint256 id,
        address owner,
        string vehicleDetails,
        uint256 premium,
        uint256 insuredAmount
    );
    event ClaimInsurance(uint256 id, address owner, uint256 insuredAmount);

    function createInsurance(
        string memory _vehicleDetails,
        uint256 _premium,
        uint256 _insuredAmount
    ) public payable {
        require(
            msg.value == _premium,
            "Premium amount must be equal to the sent value."
        );

        insuranceCount++;
        insurances[insuranceCount] = Insurance(
            insuranceCount,
            msg.sender,
            _vehicleDetails,
            _premium,
            _insuredAmount,
            false
        );
        riskPool += msg.value;

        emit NewInsurance(
            insuranceCount,
            msg.sender,
            _vehicleDetails,
            _premium,
            _insuredAmount
        );
    }

    function claimInsurance(uint256 _id, string memory _vehicleDetails) public {
        Insurance storage insurance = insurances[_id];

        require(
            insurance.owner == msg.sender,
            "Only the owner can claim the insurance."
        );
        require(
            keccak256(abi.encodePacked(insurance.vehicleDetails)) ==
                keccak256(abi.encodePacked(_vehicleDetails)),
            "Vehicle details do not match."
        );
        require(!insurance.isClaimed, "Insurance already claimed.");
        require(
            riskPool >= insurance.insuredAmount,
            "Not enough funds in the risk pool."
        );

        insurance.isClaimed = true;
        riskPool -= insurance.insuredAmount;
        balances[msg.sender] += insurance.insuredAmount;

        emit ClaimInsurance(_id, msg.sender, insurance.insuredAmount);
    }

    function withdrawFunds() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw.");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
