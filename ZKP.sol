// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZKPParameters.sol";
import "./Circuit.sol";
import "./Prover.sol";
import "./Verifier.sol";
import "./Helpers.sol";

library ZKP {
    struct Proof {
        uint256[] inputs;
        uint256[] outputs;
        uint256[] proof;
    }

    function generateProof(Circuit circuit, uint256[] memory inputs) public view returns (Proof memory) {
        // Initialize the public parameters using a trusted setup process that produces a random seed for the elliptic curve parameters
        ZKPParameters publicParams = new ZKPParameters(Helpers.randomBytes32());

        // Initialize the prover with the public parameters and circuit
        Prover prover = new Prover(publicParams, circuit);

        // Generate a proof for the given input
        Proof memory proof;
        proof.inputs = inputs;
        proof.outputs = circuit.compute(inputs);

        // Optimize the prover algorithm by using a more efficient multiplication algorithm
        proof.proof = prover.generateProof(inputs, Helpers.montgomeryMultiplication);

        return proof;
    }

    function verifyProof(Circuit circuit, Proof memory proof) public view returns (bool) {
        // Initialize the public parameters using a trusted setup process that produces a random seed for the elliptic curve parameters
        ZKPParameters publicParams = new ZKPParameters(Helpers.randomBytes32());

        // Initialize the verifier with the public parameters and circuit
        Verifier verifier = new Verifier(publicParams, circuit);

        // Verify the proof for the given input
        bool success;

        // Optimize the verifier algorithm by using a more efficient exponentiation algorithm
        success = verifier.verifyProof(proof, Helpers.montgomeryExponentiation);

        return success;
    }
}
