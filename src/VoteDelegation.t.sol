pragma solidity ^0.5.11;

import "ds-test/test.sol";

import "./VoteDelegation.sol";

contract VoteDelegationTest is DSTest {
    VoteDelegation delegation;

    function setUp() public {
        delegation = new VoteDelegation();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
