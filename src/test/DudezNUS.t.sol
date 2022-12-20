// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {DudezNUS} from "./../NamableUsingString/Dudez.sol";

contract DudezNUSTest is DSTest {

    DudezNUS deployedDudez;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    address bob = address(0x1);

    function setUp() public {
        deployedDudez = new DudezNUS();
        deployedDudez.mint(bob);
        deployedDudez.mint(bob);
    }

    function testDeploy() public {
        new DudezNUS();
    }

    function testChangeName() public {
        vm.startPrank(bob);
        deployedDudez.changeName(1, "Harry");
    }

    function testChangeBio() public {
        vm.startPrank(bob);
        deployedDudez.changeBio(1, "Harry is angry, old, smelly and bald.");
    }

    function testChangeAndGetNameEmpty() public {
        assertEq(deployedDudez.tokenNameByIndex(1), "");
    }

    function testChangeAndGetReservedEmpty() public view {
        assert(!deployedDudez.isNameReserved("Moe"));
    }

    function testChangeAndGetName() public {
        vm.startPrank(bob);
        deployedDudez.changeName(1, "Harry");
        assertEq(deployedDudez.tokenNameByIndex(1), "Harry");
    }

    function testChangeAndGetReserved() public {
        vm.startPrank(bob);
        deployedDudez.changeName(1, "Moe");
        assert(deployedDudez.isNameReserved("Moe"));
    }

    function testValidateName() public view {
        assert(deployedDudez.validateName("Katy Sue"));
    }
}