pragma solidity >=0.5.11;

import "ds-token/token.sol";
import "ds-chief/chief.sol";

contract Delegate is DSMath {
    address public owner;
    DSToken public gov;
    DSToken public iou;
    DSChief public chief;
    mapping(address => uint256) deposits;

    constructor(DSChief _chief) public {
        chief = _chief;
        owner = msg.sender;
        gov = chief.GOV();
        iou = chief.IOU();
        gov.approve(address(chief));
        iou.approve(address(chief));
    }

    modifier auth() {
        require(msg.sender == owner, "Sender must be a owner");
        _;
    }

    function lock(uint256 wad) public {
        gov.pull(msg.sender, wad);
        chief.lock(gov.balanceOf(address(this)));
        deposits[msg.sender] = add(deposits[msg.sender], wad);
    }

    function free(uint256 wad) public {
        chief.free(chief.deposits(address(this)));
        gov.push(msg.sender, wad);
        deposits[msg.sender] = sub(deposits[msg.sender], wad);
    }

    function vote(address[] memory yays) public auth returns (bytes32) {
        return chief.vote(yays);
    }
}
