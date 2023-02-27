// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZKPParameters.sol";
import "./Circuit.sol";
import "./Prover.sol";
import "./Verifier.sol";

contract ExampleUsage {
    using ZKP for ZKPParameters.Params;
    using Circuit for Circuit.CircuitDefinition;

    ZKPParameters.Params publicParams;
    Circuit.CircuitDefinition public circuit;

    constructor() {
        // Define public parameters
        publicParams = ZKPParameters.Params(0x5d6dc50c37f99d6f2097f7c58bd9d135d8bf85b1, 0x01, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed, 0x64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1, 0x188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012, 0x7192b95ffc8da78631011ed6b24cdd573f977a11e794811, 0x01);

        // Define circuit
        circuit = Circuit.CircuitDefinition();
        circuit.numInputs = 2;
        circuit.numOutputs = 1;

        uint256[] memory inputIdx = new uint256[](2);
        inputIdx[0] = 0;
        inputIdx[1] = 1;

        uint256[] memory outputIdx = new uint256[](1);
        outputIdx[0] = 2;

        circuit.addGate(Circuit.Gate(Circuit.GateType.ADD, 0, 1, 2));
        circuit.addGate(Circuit.Gate(Circuit.GateType.MUL, 0, 1, 3));
        circuit.addGate(Circuit.Gate(Circuit.GateType.MUL, 2, 3, 4));
        circuit.addGate(Circuit.Gate(Circuit.GateType.OUTPUT, 4, 0, 0, inputIdx, outputIdx));
    }

    function generateProof(uint256[] calldata inputs) public view returns (uint256[] memory) {
        Prover.Proof memory proof = Prover.generateProof(inputs, publicParams, circuit);
        return Helpers.flattenProof(proof);
    }

    function verifyProof(uint256[] calldata proof) public view returns (bool) {
        Prover.Proof memory unflattenedProof = Helpers.unflattenProof(proof, circuit.numWires);
        return Verifier.verifyProof(unflattenedProof, publicParams, circuit);
    }
}
