pragma solidity ^0.8.0;

import "./Point.sol";
import "./Curve.sol";

library EllipticCurve {
    using Point for Point.ECPoint;
    using Curve for Curve.EllipticCurve;

    function validateParameters(uint256 a, uint256 b, uint256 p) internal pure {
        require(p > 2, "EllipticCurve: modulus must be greater than 2");
        require((4*a*a*a + 27*b*b) % p != 0, "EllipticCurve: curve is singular");
    }

    function pointFromX(Curve.EllipticCurve memory curve, uint256 x) internal view returns (Point.ECPoint memory) {
        require(curve.onCurve(x, 0), "EllipticCurve: point is not on curve");
        uint256 y2 = (x*x*x + curve.a*x + curve.b) % curve.p;
        uint256 y = y2.expMod((curve.p+1)/4, curve.p);
        if (y*y % curve.p != y2) {
            y = curve.p - y;
        }
        return Point.ECPoint(x, y);
    }

    function randomPoint(Curve.EllipticCurve memory curve) internal view returns (Point.ECPoint memory) {
        uint256 x;
        uint256 y;
        do {
            x = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % curve.p;
            y = pointFromX(curve, x).y;
        } while (y == 0);

        return Point.ECPoint(x, y);
    }
}
