pragma solidity >=0.5.11;

import "ds-test/test.sol";
import "ds-token/token.sol";
import "ds-chief/chief.sol";
import "./delegate.sol";

contract DelegateOwner {
    DSChief chief;
    Delegate delegate;

    constructor(DSChief _chief) public {
        chief = _chief;
    }

    function create() public returns (Delegate) {
        return new Delegate(chief);
    }

    function vote(address[] memory yays) public {
        delegate.vote(yays);
    }
}

contract Delegator {
    DSChief chief;
    DSToken gov;

    constructor(DSChief _chief, DSToken _gov) public {
        chief = _chief;
        gov = _gov;
    }

    function approve(address gal) public {
        gov.approve(gal);
    }

    function lock(Delegate delegate, uint256 wad) public {
        delegate.lock(wad);
    }
}

contract DelegationTest is DSTest {
    DSToken gov;
    DSChief chief;
    Delegator eli;
    Delegator ava;

    function setUp() public {
        gov = new DSToken("GOV");
        DSChiefFab fab = new DSChiefFab();
        chief = fab.newChief(gov, 3);

        eli = new Delegator(chief, gov);
        ava = new Delegator(chief, gov);

        gov.mint(200 ether);
        gov.transfer(address(eli), 100 ether);
        gov.transfer(address(ava), 100 ether);
    }

    function test_create_delegation_contract() public {
        DelegateOwner dan = new DelegateOwner(chief);
        dan.create();
    }

    function test_basic_delegation() public {
        DelegateOwner dan = new DelegateOwner(chief);
        Delegate delegate = dan.create();
        require(chief.deposits(address(delegate)) == 0);
        eli.approve(address(delegate));
        eli.lock(delegate, 100 ether);
        require(chief.deposits(address(delegate)) == 100 ether);
    }
}
