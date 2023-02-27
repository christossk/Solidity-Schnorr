// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZKPParameters.sol";
import "./Circuit.sol";
import "./Prover.sol";
import "./Helpers.sol";

library Verifier {
    function verifyProof(ZKP.Proof memory proof, ZKPParameters publicParams, Circuit circuit) public view returns (bool) {
        uint256[][] memory constraints = circuit.generateConstraints(publicParams);
        uint256 numWires = constraints[0].length;
        uint256 numConstraints = constraints.length;

        // Unflatten the proof
        ZKP.Proof memory unflattenedProof = Helpers.unflattenProof(proof, numWires);

        // Check that the commitments are on the curve and that the randoms are in the field
        for (uint i = 0; i < numWires; i++) {
            require(Helpers.isOnCurve(unflattenedProof.commitments[i], publicParams), "Invalid commitment");
            require(Helpers.isInField(unflattenedProof.randoms[i]), "Invalid random");
        }

        // Check the first constraint: Each wire is either a public input or a computed value
        for (uint i = 0; i < numWires; i++) {
            if (i < proof.inputs.length) {
                require(unflattenedProof.values[i] == proof.inputs[i], "Invalid public input");
            } else {
                require(Helpers.isOnCurve(unflattenedProof.commitments[i], publicParams), "Invalid computed value");
            }
        }

        // Check the remaining constraints
        for (uint i = 1; i < numConstraints; i++) {
            uint256[] memory constraint = constraints[i];
            uint256 output = Helpers.montgomeryMultiplication(constraint[3], unflattenedProof.commitments[constraint[1]]);

            for (uint j = 0; j < constraint.length; j++) {
                output = output - Helpers.montgomeryMultiplication(constraint[j], unflattenedProof.values[j]);
            }

            require(output == 0, "Invalid constraint");
        }

        // Check the final constraint: The computed values match the public outputs
        uint256[] memory expectedOutputs = circuit.compute(proof.inputs);

        for (uint i = 0; i < expectedOutputs.length; i++) {
            require(unflattenedProof.values[proof.inputs.length + i] == expectedOutputs[i], "Invalid output");
        }

        return true;
    }
}
