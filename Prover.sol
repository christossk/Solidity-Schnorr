// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZKPParameters.sol";
import "./Circuit.sol";
import "./Helpers.sol";

library Prover {
    struct Proof {
        uint256[] values;
        uint256[] commitments;
        uint256[] randoms;
    }

    function generateProof(ZKPParameters publicParams, Circuit circuit, uint256[] memory inputs) public view returns (uint256[] memory) {
        uint256[][] memory constraints = circuit.generateConstraints(publicParams);
        uint256 numWires = constraints[0].length;
        uint256 numConstraints = constraints.length;

        // Compute the intermediate values and commitments
        uint256[] memory values = new uint256[](numWires);
        uint256[] memory commitments = new uint256[](numWires);
        uint256[] memory randoms = new uint256[](numWires);

        for (uint i = 0; i < numWires; i++) {
            if (i < inputs.length) {
                values[i] = inputs[i];
                commitments[i] = Helpers.hashToCurve(values[i], publicParams);
            } else {
                randoms[i] = Helpers.randomScalar();
                values[i] = Helpers.montgomeryMultiplication(randoms[i], publicParams.g);
                commitments[i] = Helpers.hashToCurve(values[i], publicParams);
            }
        }

        for (uint i = 0; i < numConstraints; i++) {
            uint256[] memory constraint = constraints[i];
            uint256 output = Helpers.montgomeryMultiplication(constraint[3], commitments[constraint[1]]);

            for (uint j = 0; j < constraint.length; j++) {
                output = output - Helpers.montgomeryMultiplication(constraint[j], values[j]);
            }

            values[constraint[2]] = output;
            randoms[constraint[2]] = Helpers.randomScalar();
            commitments[constraint[2]] = Helpers.hashToCurve(values[constraint[2]], publicParams, randoms[constraint[2]]);
        }

        // Generate the proof
        Proof memory proof;
        proof.values = values;
        proof.commitments = commitments;
        proof.randoms = randoms;

        return Helpers.flattenProof(proof);
    }
}
