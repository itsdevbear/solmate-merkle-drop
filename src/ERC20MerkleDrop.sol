// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation w/Merkle Tree Integration
/// @author Dev Bear (https://github.com/itsdevbear)
/// @dev Use https://github.com/miguelmota/merkletreejs to generate proofs

abstract contract ERC20MerkleDrop is ERC20 {
    bytes32 public immutable root;
    mapping(bytes32 => bool) consumeProof;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        bytes32 _root
    ) ERC20(_name, _symbol, _decimals) {
        root = _root;
    }

    /*///////////////////////////////////////////////////////////////
                              MERKLE LOGIC
    //////////////////////////////////////////////////////////////*/

    function redeem(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        bytes32 proofElement;
        bytes32 proofHash = keccak256(abi.encode(proof));
        bytes32 computedHash = keccak256(abi.encodePacked(amount, account));
        uint256 proofLength = proof.length;

        // Verify the Proof has not been used yet
        require(
            !consumeProof[proofHash],
            "ERC20MerkleDrop: Proof already Consumed"
        );

        consumeProof[proofHash] = true;
        unchecked {
            for (uint256 i = 0; i < proofLength; i += 1) {
                proofElement = proof[i];
                assembly {
                    let a := 0x20
                    let b := 0x00
                    if lt(proofElement, computedHash) {
                        a := 0x00
                        b := 0x20
                    }
                    mstore(a, computedHash)
                    mstore(b, proofElement)
                    computedHash := keccak256(0x00, 0x40)
                }
            }
        }
        require(computedHash == root, "ERC20MerkleDrop: Invalid proof");
        _mint(account, amount);
    }
}
