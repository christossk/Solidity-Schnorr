// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./ZKPParameters.sol";

library Helpers {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    function hashToCurve(uint256 x, ZKPParameters.Params memory publicParams) public pure returns (uint256) {
        bytes32 hash = keccak256(abi.encodePacked(x));
        return uint256(hash).mod(publicParams.p);
    }

    function hashToCurve(uint256 x, ZKPParameters.Params memory publicParams, uint256 random) public pure returns (uint256) {
        uint256 y = montgomeryMultiplication(x, random);
        bytes32 hash = keccak256(abi.encodePacked(x, y));
        return uint256(hash).mod(publicParams.p);
    }

    function montgomeryMultiplication(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 m = 0x8000000000000000000000000000000000000000000000000000000000000;
        uint256 abar = mulmod(a, m, publicParams.p);
        uint256 bbar = mulmod(b, m, publicParams.p);
        uint256 t = mulmod(abar, bbar, publicParams.p);
        uint256 u = mulmod(t, m.invl(), publicParams.p);
        return mulmod(u, 1, publicParams.p);
    }

    function randomScalar() public view returns (uint256) {
        bytes32 entropy = keccak256(abi.encodePacked(block.timestamp, block.number, gasleft()));
        return uint256(entropy).mod(publicParams.p);
    }

    function flattenProof(Prover.Proof memory proof) public pure returns (uint256[] memory) {
        uint256 numValues = proof.values.length;
        uint256[] memory flattenedProof = new uint256[](numValues * 3);

        for (uint i = 0; i < numValues; i++) {
            flattenedProof[i] = proof.values[i];
            flattenedProof[i + numValues] = proof.commitments[i];
            flattenedProof[i + 2 * numValues] = proof.randoms[i];
        }

        return flattenedProof;
    }

    function unflattenProof(uint256[] memory flattenedProof, uint256 numWires) public pure returns (Prover.Proof memory) {
        require(flattenedProof.length == numWires * 3, "Invalid proof length");

        Prover.Proof memory proof;
        proof.values = new uint256[](numWires);
        proof.commitments = new uint256[](numWires);
        proof.randoms = new uint256[](numWires);

        for (uint i = 0; i < numWires; i++) {
            proof.values[i] = flattenedProof[i];
            proof.commitments[i] = flattenedProof[i + numWires];
            proof.randoms[i] = flattenedProof[i + 2 * numWires];
        }

        return proof;
    }

    function isOnCurve(uint256 point, ZKPParameters.Params memory publicParams) public pure returns (bool) {
        uint256 x = point;
        uint256 y_squared = mulmod(x, x, publicParams.p);
        y_squared = mulmod(y_squared, x, publicParams.p);
        y_squared = addmod(y_squared, 7, publicParams.p);
        uint256 y = montgomerySquareRoot(y_squared, publicParams);
        return montgomeryMultiplication(y, y) == y_squared;
    }

    function isInField(uint256 scalar) public pure returns (bool) {
        return scalar < ZKPParameters.FIELD_SIZE;
    }
}