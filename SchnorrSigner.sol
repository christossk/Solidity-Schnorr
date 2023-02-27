pragma solidity ^0.8.0;

import "./SchnorrKeyPair.sol";
import "./EllipticCurve.sol";
import "./Hashing.sol";

library SchnorrSigner {
    function sign(bytes32 message, SchnorrKeyPair.KeyPair memory keyPair) internal view returns (bytes32) {
        bytes32 k = Hashing.toBytes(keyPair.publicPoint.x, keyPair.publicPoint.y, message).toKeccak256();
        uint256 r = EllipticCurve.G().mul(k).x;
        uint256 e = uint256(keccak256(abi.encodePacked(r, keyPair.publicPoint, message, address(this)))).mod(EllipticCurve.N());
        uint256 s = (k + (e * keyPair.secret)) % EllipticCurve.N();
        return bytes32((r << 256) | s);
    }
}
