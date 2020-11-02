pragma solidity^0.5.13;

// This feature is considered mature enough to not cause any
// security issues, so the possible warning should be ignored.
// As per solidity developers, "The main reason it is marked
// experimental is because it causes higher gas usage."
// See: https://github.com/ethereum/solidity/issues/5397
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

contract BlendSwap {

    mapping (bytes32 => Swap) public swaps;
    mapping (bytes32 => bytes32) public secrets;
    mapping (bytes32 => Status) public status;

    IERC20 public blend;

    struct Swap {
        address from;
        address to;
        uint amount;
        uint releaseTime;
        bytes32 secretHash;
    }

    enum Status {
        NOT_INITIALIZED,
        INITIALIZED,
        CONFIRMED,
        SECRET_REVEALED,
        REFUNDED
    }

    constructor(address blend_) public {
        blend = IERC20(blend_);
    }

    function lock(
        address to,
        uint256 amount,
        uint releaseTime,
        bytes32 secretHash,
        bool confirmed
    )
        public
    {
        require(
            status[secretHash] == Status.NOT_INITIALIZED,
            "Lock with this secretHash already exists"
        );

        swaps[secretHash] = Swap({
            from: msg.sender,
            to: to,
            amount: amount,
            releaseTime: releaseTime,
            secretHash: secretHash
        });

        if (confirmed) {
            status[secretHash] = Status.INITIALIZED;
        } else {
            status[secretHash] = Status.CONFIRMED;
        }

        blend.transferFrom(msg.sender, address(this), amount);
    }

    function confirmSwap(bytes32 secretHash) public {
        require(
            status[secretHash] == Status.INITIALIZED,
            "Wrong status"
        );

        require(
            msg.sender == swaps[secretHash].from,
            "Sender is not the initiator"
        );

        status[secretHash] = Status.CONFIRMED;
    }

    function redeem(bytes32 secretHash, bytes32 secret) public {
        require(
            status[secretHash] == Status.CONFIRMED,
            "Wrong status"
        );
        require(
            sha256(abi.encode(secret)) == swaps[secretHash].secretHash,
            "Wrong secret"
        );

        status[secretHash] = Status.SECRET_REVEALED;
        secrets[secretHash] = secret;

        blend.transfer(swaps[secretHash].to, swaps[secretHash].amount);
    }

    function claimRefund(bytes32 secretHash) public {
        require(
            block.timestamp >= swaps[secretHash].releaseTime,
            "Funds still locked"
        );
        Status st = status[secretHash];
        require(
            st == Status.INITIALIZED || st == Status.CONFIRMED,
            "Wrong status"
        );

        status[secretHash] = Status.REFUNDED;

        blend.transfer(swaps[secretHash].from, swaps[secretHash].amount);
    }
}
