pragma solidity ^0.8.0;

import "./EllipticCurve.sol";

library SchnorrKeyPair {
    using EllipticCurve for EllipticCurve.Point;

    struct KeyPair {
        uint256 secret;
        EllipticCurve.Point publicPoint;
    }

    function generate(uint256 secret) internal view returns (KeyPair memory) {
        EllipticCurve.Point memory base = EllipticCurve.G();
        EllipticCurve.Point memory publicPoint = base.mul(secret);
        return KeyPair(secret, publicPoint);
    }
}
