// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./Contract.sol";

contract Escrow {
    address[] public contracts;
    mapping(address => bool) isPayeeAllowed;
    mapping(address => bool) isContract;

    event ContractCreated(
        address indexed buyer,
        address indexed seller,
        address contractAddress
    );

    modifier onlyContract() {
        require(isContract[msg.sender], "Caller is not valid contract");
        _;
    }

    function createContract(
        address _buyer,
        address _seller,
        string memory _name,
        string memory _desc,
        uint _dueDate,
        address _escrowAddress
    ) public payable returns (address contractAddress) {
        uint amount = msg.value;
        Contract con = new Contract(
            _buyer,
            _seller,
            _name,
            _desc,
            _dueDate,
            amount,
            _escrowAddress
        );
        contracts.push(address(con));
        console.log(address(con));
        isContract[address(con)] = true;
        emit ContractCreated(_buyer, _seller, address(con));
        return address(con);
    }

    function getContractState(
        address _contractAddress
    ) public view returns (Contract.States) {
        Contract con = Contract(_contractAddress);
        return con.state();
    }

    function withdraw(address _contractAddress) public {
        Contract con = Contract(_contractAddress);
        require(msg.sender == con.seller(), "Caller is not seller");
        require(
            con.state() == Contract.States.Completed,
            "Contract not completed"
        );
        con.setClosed();
        payable(msg.sender).transfer(con.amount());
    }

    function refund(address _contractAddress) public {
        Contract con = Contract(_contractAddress);
        require(msg.sender == con.buyer(), "Caller is not buyer");
        require(
            con.state() == Contract.States.Cancelled,
            "Contract not cancelled"
        );
        con.setClosed();
        payable(msg.sender).transfer(con.amount());
    }
}
