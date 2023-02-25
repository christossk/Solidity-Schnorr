pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../contracts/Schnorr.sol";
import "../contracts/Hashing.sol";
import "../contracts/EllipticCurve.sol";

contract TestSchnorr {

    function testSchnorr() public {

        // Test key pair generation
        SchnorrKeyPair.KeyPair memory keyPair = Schnorr.generateKeyPair(123456789);
        Assert.notEqual(keyPair.publicPoint.x, 0, "Invalid key pair generated");

        // Test signature generation and verification with valid key pair and message
        bytes32 message = bytes32(uint256(123));
        Schnorr.Signature memory signature = Schnorr.sign(message, keyPair);
        Assert.isTrue(Schnorr.verify(message, signature, keyPair.publicPoint), "Signature is invalid");

        // Test signature verification with invalid message
        bytes32 invalidMessage = bytes32(uint256(456));
        Assert.isFalse(Schnorr.verify(invalidMessage, signature, keyPair.publicPoint), "Invalid message passed verification");

        // Test signature verification with invalid public key
        EllipticCurve.Point memory invalidPublicKey = EllipticCurve.Point(0, 0);
        Assert.isFalse(Schnorr.verify(message, signature, invalidPublicKey), "Invalid public key passed verification");

        // Test signature verification with invalid signature
        Schnorr.Signature memory invalidSignature = Schnorr.Signature(bytes32(123), bytes32(456));
        Assert.isFalse(Schnorr.verify(message, invalidSignature, keyPair.publicPoint), "Invalid signature passed verification");

        // Test signature verification with an equal point as the public key
        SchnorrKeyPair.KeyPair memory equalKeyPair = Schnorr.generateKeyPair(1);
        EllipticCurve.Point memory equalPoint = equalKeyPair.publicPoint.add(equalKeyPair.publicPoint);
        Assert.isTrue(Schnorr.verify(message, signature, equalPoint), "Equal point passed verification");

        // Test signature verification with the negation of the public key
        SchnorrKeyPair.KeyPair memory negationKeyPair = Schnorr.generateKeyPair(1);
        EllipticCurve.Point memory negationPoint = EllipticCurve.Point(negationKeyPair.publicPoint.x, negationKeyPair.publicPoint.y.negateMod(EllipticCurve.P()));
        Assert.isTrue(Schnorr.verify(message, signature, negationPoint), "Negation point passed verification");

        // Test signature generation with a large private key
        uint256 privateKey = 2**256 - 2**32 - 977;
        SchnorrKeyPair.KeyPair memory largeKeyPair = Schnorr.generateKeyPair(privateKey);
        Assert.notEqual(largeKeyPair.publicPoint.x, 0, "Invalid key pair generated with large private key");
        bytes32 largeMessage = bytes32(uint256(987654321));
        Schnorr.Signature memory largeSignature = Schnorr.sign(largeMessage, largeKeyPair);
        Assert.isTrue(Schnorr.verify(largeMessage, largeSignature, largeKeyPair.publicPoint), "Signature with large private key is invalid");

            // Test signature generation with a zero private key
    SchnorrKeyPair.KeyPair memory zeroKeyPair = Schnorr.generateKeyPair(0);
    Assert.notEqual(zeroKeyPair.publicPoint.x, 0, "Invalid key pair generated with zero private key");
    bytes32 zeroMessage = bytes32(uint256(111));
    Schnorr.Signature memory zeroSignature = Schnorr.sign(zeroMessage, zeroKeyPair);
    Assert.isTrue(Schnorr.verify(zeroMessage, zeroSignature, zeroKeyPair.publicPoint), "Signature with zero private key is invalid");

    // Test signature verification with a message that is a packed ECPoint
    SchnorrKeyPair.KeyPair memory packedKeyPair = Schnorr.generateKeyPair(1);
    EllipticCurve.Point memory packedPoint = EllipticCurve.Point(123, 456);
    bytes32 packedMessage = Hashing.sha256(abi.encodePacked(packedPoint.x, packedPoint.y));
    Schnorr.Signature memory packedSignature = Schnorr.sign(packedMessage, packedKeyPair);
    Assert.isTrue(Schnorr.verify(packedMessage, packedSignature, packedKeyPair.publicPoint), "Packed ECPoint message signature verification failed");

    // Test signature verification with a message that is a packed ECPoint and additional data
    bytes memory extraData = abi.encodePacked(uint256(789));
    bytes32 packedExtraDataMessage = Hashing.sha256(abi.encodePacked(packedPoint.x, packedPoint.y, extraData));
    Schnorr.Signature memory packedExtraDataSignature = Schnorr.sign(packedExtraDataMessage, packedKeyPair);
    Assert.isTrue(Schnorr.verify(packedExtraDataMessage, packedExtraDataSignature, packedKeyPair.publicPoint), "Packed ECPoint message with extra data signature verification failed");

    // Test signature verification with a message that is a packed ECPoint and additional data where the message is verified
    bytes32 packedExtraDataVerifiedMessage = Hashing.sha256(abi.encodePacked(packedPoint.x, packedPoint.y, extraData, Schnorr.verifyTag()));
    Schnorr.Signature memory packedExtraDataVerifiedSignature = Schnorr.sign(packedExtraDataVerifiedMessage, packedKeyPair);
    Assert.isTrue(Schnorr.verify(packedExtraDataVerifiedMessage, packedExtraDataVerifiedSignature, packedKeyPair.publicPoint), "Packed ECPoint message with extra data and verify tag signature verification failed");
}
}
