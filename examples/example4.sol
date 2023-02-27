pragma solidity ^0.8.0;

import "./Schnorr.sol";

contract SignatureExample {
    using Schnorr for bytes32;

    function signMessage(bytes32 message, uint256 privateKey) public pure returns (bytes memory) {
        SchnorrKeyPair.KeyPair memory keyPair = Schnorr.generateKeyPair(privateKey);
        Schnorr.Signature memory signature = Schnorr.sign(message, keyPair);
        return signature.toBytes();
    }

    function verifySignature(bytes32 message, bytes memory signatureBytes, EllipticCurve.Point memory publicKey) public pure returns (bool) {
        Schnorr.Signature memory signature = Schnorr.Signature.fromBytes(signatureBytes);
        return Schnorr.verify(message, signature, publicKey);
    }
}
