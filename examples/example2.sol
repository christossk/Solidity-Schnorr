pragma solidity ^0.8.0;

import "./Schnorr.sol";
import "./EllipticCurve.sol";
import "./Hashing.sol";

contract MessageVerifier {
    using Schnorr for Schnorr.Signature;
    using EllipticCurve for EllipticCurve.Point;

    SchnorrKeyPair.KeyPair private keyPair = Schnorr.generateKeyPair(12345);

    function verify(bytes memory message, bytes memory signature) public view returns (bool) {
        bytes32 hashedMessage = Hashing.sha256(message);
        Schnorr.Signature memory sig = Schnorr.Signature.fromBytes(signature);
        return sig.verify(hashedMessage, keyPair.publicPoint);
    }
}
