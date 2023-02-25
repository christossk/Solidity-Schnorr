pragma solidity ^0.8.0;

import "./Schnorr.sol";

contract AuthExample {
    mapping(address => bytes32) private userSecrets;

    function register(bytes32 secret) public {
        // Generate a key pair for the user's secret
        SchnorrKeyPair.KeyPair memory keyPair = Schnorr.generateKeyPair(uint256(secret));

        // Store the public key in the contract for authentication later
        userSecrets[msg.sender] = keyPair.publicPoint.x;
    }

    function authenticate(bytes32 challenge, Schnorr.Signature memory signature) public view returns (bool) {
        // Look up the user's public key
        bytes32 publicKey = userSecrets[msg.sender];

        // Verify the signature with the user's public key and the challenge
        return Schnorr.verify(challenge, signature, EllipticCurve.Point(uint256(publicKey), 0));
    }
}
