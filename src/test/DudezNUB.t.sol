// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {DudezBUS} from "./../NamableUsingBytes/Dudez.sol";

contract DudezNUBTest is DSTest {

    DudezBUS deployedDudez;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    address bob = address(0x1);

    function setUp() public {
        deployedDudez = new DudezBUS();
        //vm.etch(address(dudezContract), deployedDudez.code);
        deployedDudez.mint(bob);
        deployedDudez.mint(bob);
    }

    function testDeploy() public {
        new DudezBUS();
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

    function testValidateNameInvalidWithLeadingSpace() public view {
        assert(!deployedDudez.validateName(" Katy Sue"));
    }

    function testValidateNameInvalidWithContinousSpace() public view {
        assert(!deployedDudez.validateName("Katy  Sue"));
    }

    function testValidateNameInvalidWithTrailing() public view {
        assert(!deployedDudez.validateName("Katy Sue "));
    }

    function testValidateNameInvalidWhenEmpty() public view {
        assert(!deployedDudez.validateName(""));
    }

    function testValidateNameBeforeInvalidOnOverflow() public view {       
        assert(deployedDudez.validateName("abcdefghijklmnopqrstuvwxyzabcdef"));
        //test with a trailing space as well to ensure last char validation
        assert(!deployedDudez.validateName("abcdefghijklmnopqrstuvwxyzabcde "));
        //results in a compiler error 33 chars cant fit in bytes32
        //assert(deployedDudez.validateName("abcdefghijklmnopqrstuvwxyzabcdefg"));
    }

    function testEnsuringNearlyOverflowingName() public {
        vm.startPrank(bob);
        deployedDudez.changeName(1, "abcdefghijklmnopqrstuvwxyzabcdef");
        assert(deployedDudez.isNameReserved("abcdefghijklmnopqrstuvwxyzabcdef"));
        assertEq(deployedDudez.tokenNameByIndex(1), "abcdefghijklmnopqrstuvwxyzabcdef");
    }
}