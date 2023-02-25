pragma solidity ^0.8.0;

import "./EllipticCurve.sol";

library Point {
    using EllipticCurve for uint256;
    using EllipticCurve for EllipticCurve.Point;

    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    function fromECPoint(EllipticCurve.Point memory p) internal pure returns (ECPoint memory) {
        return ECPoint(p.x, p.y);
    }

    function toECPoint(ECPoint memory p) internal pure returns (EllipticCurve.Point memory) {
        return EllipticCurve.Point(p.x, p.y);
    }

    function add(ECPoint memory p, ECPoint memory q) internal view returns (ECPoint memory) {
        EllipticCurve.Point memory pEC = toECPoint(p);
        EllipticCurve.Point memory qEC = toECPoint(q);
        return fromECPoint(pEC.add(qEC));
    }

    function mul(ECPoint memory p, uint256 scalar) internal view returns (ECPoint memory) {
        EllipticCurve.Point memory pEC = toECPoint(p);
        return fromECPoint(pEC.mul(scalar));
    }
}
