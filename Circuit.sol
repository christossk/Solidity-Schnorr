// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZKPParameters.sol";

library Circuit {
    function compute(uint256[] memory inputs) public pure returns (uint256[] memory) {
        // Define the circuit logic that takes an array of input values and produces an array of output values
        uint256[] memory outputs = new uint256[](inputs.length);

        for (uint i = 0; i < inputs.length; i++) {
            // Perform some computation on the input value to produce the corresponding output value
            outputs[i] = inputs[i] * inputs[i];
        }

        return outputs;
    }

    function generateConstraints(ZKPParameters.Params memory publicParams) public pure returns (uint256[][] memory) {
        // Define the constraints for the circuit
        uint256[][] memory constraints = new uint256[][](3);

        // First constraint: Each wire is either a public input or a computed value
        constraints[0] = new uint256[](4);
        constraints[0][0] = 1;
        constraints[0][1] = 0;
        constraints[0][2] = 0;
        constraints[0][3] = 0;

        // Second constraint: The computed values satisfy the circuit logic
        constraints[1] = new uint256[](4);
        constraints[1][0] = 0;
        constraints[1][1] = 1;
        constraints[1][2] = 0;
        constraints[1][3] = publicParams.g;

        // Third constraint: The computed values match the public outputs
        constraints[2] = new uint256[](4);
        constraints[2][0] = 0;
        constraints[2][1] = 0;
        constraints[2][2] = 1;
        constraints[2][3] = publicParams.h;

        return constraints;
    }
}
