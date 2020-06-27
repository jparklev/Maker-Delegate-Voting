pragma solidity >=0.5.11;

import "ds-token/token.sol";
import "ds-chief/chief.sol";

/// @dev Vote MKR tokens with a hot key and ensure all assets are returned to a cold key.
/// Expected flow: originate a contract with hot, cold keys; pointed to an active DSChief
/// voting contract. Deposits funds directly in this contract. lock()/vote() those funds
/// as desired using the hot key. release() funds back to the cold key.
contract VoteProxy is DSMath {
    address public cold;
    address public hot;
    DSToken public gov;
    DSToken public iou;
    DSChief public chief;
    mapping(address => uint256) deposits;

    constructor(
        DSChief _chief,
        address _cold,
        address _hot
    ) public {
        chief = _chief;
        cold = _cold;
        hot = _hot;

        gov = chief.GOV();
        iou = chief.IOU();
        gov.approve(address(chief));
        iou.approve(address(chief));
    }

    modifier auth() {
        require(
            msg.sender == hot || msg.sender == cold,
            "Sender must be a Cold or Hot Wallet"
        );
        _;
    }

    function lock(uint256 wad) public {
        gov.pull(msg.sender, wad);
        chief.lock(gov.balanceOf(address(this)));
        deposits[msg.sender] = add(deposits[msg.sender], wad);
    }

    function free(uint256 wad) public {
        chief.free(chief.deposits(address(this)));
        deposits[msg.sender] = sub(deposits[msg.sender], wad);
        gov.push(msg.sender, wad);
    }

    function vote(address[] memory yays) public auth returns (bytes32) {
        return chief.vote(yays);
    }
}
