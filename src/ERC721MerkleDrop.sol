// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";

/// @notice Modern and gas efficient ERC721 + EIP-2612 implementation w/Merkle Tree Integration
/// @author Dev Bear (https://github.com/itsdevbear)
/// @dev Use https://github.com/miguelmota/merkletreejs to generate proofs

abstract contract ERC721MerkleDrop is ERC721 {
    bytes32 public immutable root;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        bytes32 _root
    ) ERC721(_name, _symbol) {
        root = _root;
    }

    /*///////////////////////////////////////////////////////////////
                              MERKLE LOGIC
    //////////////////////////////////////////////////////////////*/

    function redeem(
        address account,
        uint256 tokenId,
        bytes32[] calldata proof
    ) external {
        bytes32 proofElement;
        bytes32 computedHash = keccak256(abi.encodePacked(tokenId, account));
        uint256 proofLength = proof.length;
        for (uint256 i = 0; i < proofLength; i += 1) {
            proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }
        require(computedHash == root, "ERC721MerkleDrop: Invalid proof");
        _mint(account, tokenId);
    }
}
