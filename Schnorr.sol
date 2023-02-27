pragma solidity ^0.8.0;

import "./SchnorrKeyPair.sol";
import "./SchnorrSigner.sol";
import "./SchnorrVerifier.sol";

library Schnorr {
    struct Signature {
        bytes32 r;
        bytes32 s;
    }

    function generateKeyPair(uint256 secret) internal view returns (SchnorrKeyPair.KeyPair memory) {
        return SchnorrKeyPair.generate(secret);
    }

    function sign(bytes32 message, SchnorrKeyPair.KeyPair memory keyPair) internal view returns (Signature memory) {
        bytes32 signature = SchnorrSigner.sign(message, keyPair);
        return Signature(bytes32(signature >> 256), bytes32(signature));
    }

    function verify(bytes32 message, Signature memory signature, EllipticCurve.Point memory publicKey) internal view returns (bool) {
        bytes32 schnorrSignature = bytes32((uint256(signature.r) << 256) | uint256(signature.s));
        return SchnorrVerifier.verify(message, schnorrSignature, publicKey);
    }
}
