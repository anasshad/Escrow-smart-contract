// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./Escrow.sol";

contract Contract {
    Escrow escrowContract;
    address escrowContractAddress;
    address public buyer;
    address public seller;
    string public name;
    string public desc;
    uint public dueDate;
    uint public amount;
    uint public deliveryTime;

    enum States {
        Started, //initial default state
        Inprocess, //contract has started
        Pastdue, //contract is past due
        Delivered, //buyer has delivered
        Completed, //seller has approved order
        Closed //payment have been withdrawn
    }

    States public state = States.Started;

    modifier onlySeller() {
        require(msg.sender == seller, "Caller is not seller");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Caller is not buyer");
        _;
    }

    modifier onlyAdminContract() {
        require(msg.sender == escrowContractAddress, "Not admin contract");
        _;
    }

    constructor(
        address _buyer,
        address _seller,
        string memory _name,
        string memory _desc,
        uint _dueDate,
        uint _amount,
        address _escrowAddress
    ) {
        buyer = _buyer;
        seller = _seller;
        name = _name;
        desc = _desc;
        dueDate = _dueDate;
        amount = _amount;

        state = States.Inprocess;
        escrowContract = Escrow(_escrowAddress);
        escrowContractAddress = _escrowAddress;
    }

    function deliver() public onlySeller {
        require(state == States.Inprocess, "Contract is not under process");
        if (block.timestamp <= dueDate) {
            state = States.Delivered;
            deliveryTime = block.timestamp;
        } else {
            state = States.Pastdue;
            deliveryTime = block.timestamp;
        }
    }

    function approve() public onlyBuyer {
        require(state == States.Delivered, "Contract is not delivered");
        state = States.Completed;
    }

    function setClosed() public onlyAdminContract {
        state = States.Closed;
    }
}
