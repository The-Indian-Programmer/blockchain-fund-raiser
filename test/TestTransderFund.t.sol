// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {DeployTransferFund} from "../script/DeployTransferFund.d.sol";
import {TransferFund} from "../src/TransferFund.sol";

// import {StdCheats} from "forge-std/StdCheats.sol";

contract TestTransferFund is Test {
    TransferFund tranferFund;

    address public immutable owner; // to store the address of contract owner
    uint256 public constant STARTING_USER_BALANCE = 100 ether; // to store the starting balance of user
    uint256 public constant SEND_VALUE = 0.1 ether; // to store the value to be sent

    constructor() {
        owner = msg.sender; // set the owner of the contract
    }

    address bob = makeAddr("bob"); // to store the address of bob
    address alice = makeAddr("alice"); // to store the address of alice

    function setUp() public {
        DeployTransferFund deployTranferFund = new DeployTransferFund();
        tranferFund = deployTranferFund.run();
        vm.deal(bob, STARTING_USER_BALANCE);
        vm.deal(alice, STARTING_USER_BALANCE);
    }

    /* 
        These can be the possible test cases for the contract
        1. User Deposits Funds Successfully: Test that a user can deposit funds into the contract successfully.
        2. User Withdraws Their Own Funds: Test that a user can withdraw their own funds from the contract.
        3. User Withdraws Zero Funds: Test that a user cannot withdraw zero funds from the contract.
        4. User Withdraws More Than Their Balance: Test that a user cannot withdraw more funds than they have deposited.
        5. User Withdraws All Funds: Test that a user can withdraw all their funds from the contract.
        6. Owner Withdraws All Funds: Test that the contract owner can withdraw all the funds from the contract.
        7. User Tries to Withdraw After Owner Withdrawal: Test that a user cannot withdraw funds after the owner has withdrawn all the funds.
        8. User Sends Funds to Owner: Test that a user cannot directly send funds to the owner address.
        9. Multiple Users Deposit Funds and Withdraw: Test that multiple users can deposit funds and withdraw their respective funds independently.
        10. Contract Balance After User Deposits: Test that the contract balance increases correctly after a user deposits funds.
        11. Contract Balance After User Withdraws: Test that the contract balance decreases correctly after a user withdraws funds.
        12. Contract Balance After Owner Withdraws: Test that the contract balance becomes zero after the owner withdraws all the funds.
        13. Fallback Function Rejects Incoming Ether: Test that the fallback function rejects incoming ether transactions.
        14. Contract Events: Test that the appropriate events are emitted during deposit and withdrawal operations.
    */

    // 1. User can deposit the fund successfully
    function testUserCanDepositTheFund() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        vm.stopPrank();
        assertEq(tranferFund.getTotalAmount(), SEND_VALUE);
    }

    // 2. Revert if user tries to deposit the zero fund
    function testUserCannotDepositZeroFund() public {
        vm.startPrank(bob);
        vm.expectRevert();
        tranferFund.payAmount{value: 0}("Bob");
        vm.stopPrank();
        assertEq(tranferFund.getTotalAmount(), 0);
    }

    // 3. Revert if user tries to deposit the fund without name
    function testUserCannotDepositFundWithoutName() public {
        vm.startPrank(bob);
        vm.expectRevert();
        tranferFund.payAmount{value: SEND_VALUE}("");
        vm.stopPrank();
        assertEq(tranferFund.getTotalAmount(), 0);
    }

    // 4. Total Amount should be updated after user deposit the fund
    function testTotalAmountShouldBeUpdatedAfterUserDepositTheFund() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        vm.stopPrank();

        vm.startPrank(alice);
        tranferFund.payAmount{value: SEND_VALUE}("Alice");
        vm.stopPrank();

        uint256 totalAmount = tranferFund.getTotalAmount();
        assertEq(totalAmount, SEND_VALUE * 2);
    }

    // 5. User can withdraw the fund successfully
    function testUserCanWithDrawFund() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        tranferFund.withDrawYourAmount();
        vm.stopPrank();
    }

    // 6. Revert if user tries to withdraw the fund without depositing
    function testUserCanNotWithDrawFundWithoutDeposit() public {
        vm.startPrank(bob);
        vm.expectRevert();
        tranferFund.withDrawYourAmount();
        vm.stopPrank();
    }

    // 7. Revert if user tries to withdraw the fund twice
    function testUserCanNotWithDrawFundTwice() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        tranferFund.withDrawYourAmount();
        vm.expectRevert();
        tranferFund.withDrawYourAmount();
        vm.stopPrank();
    }

    // 8. Revert if user tries to withdraw the fund more than deposited
    function testUserCanNotWithDrawFundMoreThanDeposited() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        tranferFund.withDrawYourAmount();
        vm.expectRevert();
        tranferFund.withDrawYourAmount();
        vm.stopPrank();
    }

    // 9. Contract owner can withdraw the fund successfully
    function testOwnerCanWithDrawFund() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        vm.stopPrank();
        vm.startPrank(owner);
        tranferFund.withDrawAmount();
        vm.stopPrank();
        console.log(tranferFund.getOwner());
        assertEq(tranferFund.getOwner(), owner);
    }

    // 10. Revert if user tries to withdraw the fund after owner withdraws
    function testUserCanNotWithDrawFundAfterOwnerWithDraws() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        vm.stopPrank();
        vm.startPrank(owner);
        tranferFund.withDrawAmount();
        vm.stopPrank();
        vm.startPrank(bob);
        vm.expectRevert();
        tranferFund.withDrawYourAmount();
        vm.stopPrank();
    }

    // 13. function to test the owner of the contract
    function testContractOwner() public {
        assertEq(tranferFund.getOwner(), owner);
    }

    // 14. function to test the total amount
    function testTotalAmount() public {
        assertEq(tranferFund.getTotalAmount(), 0);
    }
    

    // 15. function to test the total amount
    function testTotalAmountAfterDeposit() public {
        vm.startPrank(bob);
        tranferFund.payAmount{value: SEND_VALUE}("Bob");
        vm.stopPrank();
        assertEq(tranferFund.getTotalAmount(), SEND_VALUE);
    }


    // function to test the total address of contract
    function testTotalAddressOfContract() public {
        assertEq(tranferFund.getAddress(), address(tranferFund));
    }

}
