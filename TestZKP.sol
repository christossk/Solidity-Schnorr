pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ZKP.sol";

contract TestZKP {
    function testExampleCircuit() public {
        ZKP.ZKPParameters memory params = ZKP.ZKPParameters({
            p: 21888242871839275222246405745257275088548364400416034343698204186575808495617,
            a: 0,
            b: 3,
            Gx: 1,
            Gy: 2,
            n: 21888242871839275222246405745257275088597270413166387531887782885972891924521,
            h: 1
        });

        ZKP.CircuitDefinition memory circuit = ZKP.CircuitDefinition({
            numInputs: 2,
            numOutputs: 1,
            numWires: 4,
            gates: new ZKP.Gate[](3)
        });

        circuit.gates[0] = ZKP.Gate({
            gateType: ZKP.GateType.And,
            inputWires: new uint256[](2),
            outputWire: 2
        });

        circuit.gates[1] = ZKP.Gate({
            gateType: ZKP.GateType.Or,
            inputWires: new uint256[](2),
            outputWire: 3
        });

        circuit.gates[2] = ZKP.Gate({
            gateType: ZKP.GateType.And,
            inputWires: new uint256[](2),
            outputWire: 4
        });

        circuit.gates[0].inputWires[0] = 0;
        circuit.gates[0].inputWires[1] = 1;
        circuit.gates[1].inputWires[0] = 2;
        circuit.gates[1].inputWires[1] = 3;
        circuit.gates[2].inputWires[0] = 2;
        circuit.gates[2].inputWires[1] = 3;

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = 1;
        inputs[1] = 0;

        uint256[] memory outputs = new uint256[](1);
        outputs[0] = 1;

        ZKP.Prover.Proof memory proof = ZKP.Prover.generateProof(inputs, params, circuit);
        bool result = ZKP.Verifier.verifyProof(proof, params, circuit, outputs);

        Assert.equal(result, true, "Proof should be verified successfully");
    }

    function testHashToCurve() public {
        ZKP.ZKPParameters memory params = ZKP.ZKPParameters({
            p: 21888242871839275222246405745257275088548364400416034343698204186575808495617,
            a: 0,
            b: 3,
            Gx: 1,
            Gy: 2,
            n: 21888242871839275222246405745257275088597270413166387531887782885972891924521,
            h: 1
        });

        uint256 hashValue = 123;
        uint256 randomScalar = 456;

        ZKP.CurvePoint memory point1 = ZKP.Helpers.hashToCurve(hashValue, params);
        ZKP.CurvePoint memory point2 = ZKP.Helpers.hashToCurve(hashValue, params, randomScalar);

                Assert.isTrue(ZKP.Helpers.isOnCurve(point1.x, params), "Point 1 should be on the curve");
        Assert.isTrue(ZKP.Helpers.isOnCurve(point2.x, params), "Point 2 should be on the curve");
    }

    function testScalarInField() public {
        ZKP.ZKPParameters memory params = ZKP.ZKPParameters({
            p: 21888242871839275222246405745257275088548364400416034343698204186575808495617,
            a: 0,
            b: 3,
            Gx: 1,
            Gy: 2,
            n: 21888242871839275222246405745257275088597270413166387531887782885972891924521,
            h: 1
        });

        uint256 scalar1 = 123;
        uint256 scalar2 = params.p + 1;

        Assert.isTrue(ZKP.Helpers.isInField(scalar1), "Scalar 1 should be in the field");
        Assert.isFalse(ZKP.Helpers.isInField(scalar2), "Scalar 2 should not be in the field");
    }

    function testInvalidProof() public {
        ZKP.ZKPParameters memory params = ZKP.ZKPParameters({
            p: 21888242871839275222246405745257275088548364400416034343698204186575808495617,
            a: 0,
            b: 3,
            Gx: 1,
            Gy: 2,
            n: 21888242871839275222246405745257275088597270413166387531887782885972891924521,
            h: 1
        });

        ZKP.CircuitDefinition memory circuit = ZKP.CircuitDefinition({
            numInputs: 2,
            numOutputs: 1,
            numWires: 4,
            gates: new ZKP.Gate[](3)
        });

        circuit.gates[0] = ZKP.Gate({
            gateType: ZKP.GateType.And,
            inputWires: new uint256[](2),
            outputWire: 2
        });

        circuit.gates[1] = ZKP.Gate({
            gateType: ZKP.GateType.Or,
            inputWires: new uint256[](2),
            outputWire: 3
        });

        circuit.gates[2] = ZKP.Gate({
            gateType: ZKP.GateType.And,
            inputWires: new uint256[](2),
            outputWire: 4
        });

        circuit.gates[0].inputWires[0] = 0;
        circuit.gates[0].inputWires[1] = 1;
        circuit.gates[1].inputWires[0] = 2;
        circuit.gates[1].inputWires[1] = 3;
        circuit.gates[2].inputWires[0] = 2;
        circuit.gates[2].inputWires[1] = 3;

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = 1;
        inputs[1] = 0;

        uint256[] memory outputs = new uint256[](1);
        outputs[0] = 1;

        ZKP.Prover.Proof memory proof = ZKP.Prover.generateProof(inputs, params, circuit);
        proof.inputs[0] = 0;

        bool result = ZKP.Verifier.verifyProof(proof, params, circuit, outputs);

                Assert.equal(result, false, "Proof with invalid input should not be verified successfully");
    }

    function testDifferentOutputs() public {
        ZKP.ZKPParameters memory params = ZKP.ZKPParameters({
            p: 21888242871839275222246405745257275088548364400416034343698204186575808495617,
            a: 0,
            b: 3,
            Gx: 1,
            Gy: 2,
            n: 21888242871839275222246405745257275088597270413166387531887782885972891924521,
            h: 1
        });

        ZKP.CircuitDefinition memory circuit = ZKP.CircuitDefinition({
            numInputs: 2,
            numOutputs: 1,
            numWires: 4,
            gates: new ZKP.Gate[](3)
        });

        circuit.gates[0] = ZKP.Gate({
            gateType: ZKP.GateType.And,
            inputWires: new uint256[](2),
            outputWire: 2
        });

        circuit.gates[1] = ZKP.Gate({
            gateType: ZKP.GateType.Or,
            inputWires: new uint256[](2),
            outputWire: 3
        });

        circuit.gates[2] = ZKP.Gate({
            gateType: ZKP.GateType.And,
            inputWires: new uint256[](2),
            outputWire: 4
        });

        circuit.gates[0].inputWires[0] = 0;
        circuit.gates[0].inputWires[1] = 1;
        circuit.gates[1].inputWires[0] = 2;
        circuit.gates[1].inputWires[1] = 3;
        circuit.gates[2].inputWires[0] = 2;
        circuit.gates[2].inputWires[1] = 3;

        uint256[] memory inputs = new uint256[](2);
        inputs[0] = 1;
        inputs[1] = 0;

        uint256[] memory outputs1 = new uint256[](1);
        outputs1[0] = 1;

        uint256[] memory outputs2 = new uint256[](1);
        outputs2[0] = 0;

        ZKP.Prover.Proof memory proof = ZKP.Prover.generateProof(inputs, params, circuit);
        bool result1 = ZKP.Verifier.verifyProof(proof, params, circuit, outputs1);
        bool result2 = ZKP.Verifier.verifyProof(proof, params, circuit, outputs2);

        Assert.equal(result1, true, "Proof with correct output should be verified successfully");
        Assert.equal(result2, false, "Proof with incorrect output should not be verified successfully");
    }}
