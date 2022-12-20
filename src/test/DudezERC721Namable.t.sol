// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {Dudez} from "./../ERC721Namable/Dudez.sol";

contract DudezERC721NamableTest is DSTest {

    Dudez deployedDudez;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    address bob = address(0x1);

    function setUp() public {
        deployedDudez = new Dudez();
        deployedDudez.mint(bob, 1);
    }

    function testDeploy() public {
        new Dudez();
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