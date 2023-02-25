pragma solidity ^0.8.0;

import "./Schnorr.sol";

contract Example1 {
    SchnorrKeyPair.KeyPair keyPair;

    constructor() {
        keyPair = Schnorr.generateKeyPair(123456789);
    }

    function signAndVerify(bytes32 message) public view returns (bool) {
        Schnorr.Signature memory signature = Schnorr.sign(message, keyPair);
        return Schnorr.verify(message, signature, keyPair.publicPoint);
    }
}
