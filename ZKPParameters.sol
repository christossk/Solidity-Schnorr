// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library ZKPParameters {
    struct Params {
        uint256 p; // Prime modulus
        uint256 g; // Generator for the cyclic group of order p
        uint256 h; // Hash point for the Fiat-Shamir transform
    }

    function newParams(bytes32 seed) public pure returns (Params memory) {
        // Use the seed to generate the public parameters
        uint256 p = uint256(keccak256(abi.encodePacked("p", seed)));
        uint256 g = uint256(keccak256(abi.encodePacked("g", seed)));
        uint256 h = uint256(keccak256(abi.encodePacked("h", seed)));

        return Params(p, g, h);
    }
}
