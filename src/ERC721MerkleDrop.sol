// SPDX-License-Identifier:
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";

abstract contract ERC721MerkleDrop is ERC721 {
    bytes32 public immutable root;

    constructor(
        string memory _name,
        string memory _symbol,
        bytes32 _root
    ) {
        name = _name;
        symbol = _symbol;
        root = _root;
    }

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
        _safeMint(account, tokenId);
    }
}
