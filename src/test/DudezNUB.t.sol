// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {DudezBUS} from "./../NamableUsingBytes/Dudez.sol";

contract DudezNUBTest is DSTest {

    DudezBUS dudezContract;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    address bob = address(0x1);

    function setUp() public {
        address deployedDudez = address(new DudezBUS());
        vm.etch(address(dudezContract), deployedDudez.code);
        dudezContract.mint(bob);
        dudezContract.mint(bob);
    }

    function testDeploy() public {
        new DudezBUS();
    }

    function testChangeName() public {
        vm.startPrank(bob);
        dudezContract.changeName(1, "Harry");
    }

    function testChangeBio() public {
        vm.startPrank(bob);
        dudezContract.changeBio(1, "Harry is angry, old, smelly and bald.");
    }

    function testChangeAndGetNameEmpty() public {
        assertEq(dudezContract.tokenNameByIndex(1), "");
    }

    function testChangeAndGetReservedEmpty() public view {
        assert(!dudezContract.isNameReserved("Moe"));
    }

    function testChangeAndGetName() public {
        vm.startPrank(bob);
        dudezContract.changeName(1, "Harry");
        assertEq(dudezContract.tokenNameByIndex(1), "Harry");
    }

    function testChangeAndGetReserved() public {
        vm.startPrank(bob);
        dudezContract.changeName(1, "Moe");
        assert(dudezContract.isNameReserved("Moe"));
    }

    function testValidateName() public view {
        assert(dudezContract.validateName("Katy Sue"));
    }
}