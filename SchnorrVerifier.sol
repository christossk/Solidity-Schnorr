pragma solidity ^0.8.0;

import "./EllipticCurve.sol";
import "./Hashing.sol";

library SchnorrVerifier {
    function verify(bytes32 message, bytes32 signature, EllipticCurve.Point memory publicKey) internal view returns (bool) {
        require(publicKey.isOnCurve(), "Invalid public key");

        uint256 r = uint256(signature >> 256);
        uint256 s = uint256(signature);
        require(r > 0 && r < EllipticCurve.P(), "Invalid signature");
        require(s > 0 && s < EllipticCurve.N(), "Invalid signature");

        bytes32 k = Hashing.toBytes(publicKey.x, publicKey.y, message).toKeccak256();
        EllipticCurve.Point memory R = EllipticCurve.G().mul(s).subtract(publicKey.mul(r));
        uint256 e = uint256(keccak256(abi.encodePacked(R.x, R.y, publicKey, message, address(this)))).mod(EllipticCurve.N());
        return r == R.x && e == uint256(signature).mod(EllipticCurve.N());
    }
}
