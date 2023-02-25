pragma solidity ^0.8.0;

library Curve {
    uint256 constant private A = 0;
    uint256 constant private B = 7;
    uint256 constant private P = 2**256 - 2**32 - 977;
    uint256 constant private N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    struct EllipticCurve {
        uint256 a;
        uint256 b;
        uint256 p;
        uint256 n;
    }

    function secp256k1() internal pure returns (EllipticCurve memory) {
        return EllipticCurve(A, B, P, N);
    }

    function onCurve(EllipticCurve memory curve, uint256 x, uint256 y) internal pure returns (bool) {
    return y*y == (x*x*x + curve.a*x + curve.b) % curve.p;
}


    function negate(EllipticCurve memory curve, uint256 x, uint256 y) internal pure returns (uint256, uint256) {
        return (x, curve.p-y);
    }

    function add(EllipticCurve memory curve, uint256 x1, uint256 y1, uint256 x2, uint256 y2) internal view returns (uint256, uint256) {
        uint256 s;
        uint256 x3;
        uint256 y3;

        if (x1 == x2 && y1 == y2) {
            (s, x3, y3) = double(curve, x1, y1);
        } else {
            (s, x3, y3) = add(curve, x1, y1, x2, y2);
        }

        return (x3, y3);
    }

    function double(EllipticCurve memory curve, uint256 x, uint256 y) private view returns (uint256, uint256, uint256) {
        uint256 s = ((3*x*x + curve.a) * inverseMod(2*y, curve.p)) % curve.p;
        uint256 x3 = (s*s - 2*x) % curve.p;
        uint256 y3 = (s*(x - x3) - y) % curve.p;

        return (s, x3, y3);
    }

    function add(EllipticCurve memory curve, uint256 x1, uint256 y1, uint256 x2, uint256 y2) private view returns (uint256, uint256, uint256) {
        uint256 s = ((y2 - y1) * inverseMod(x2 - x1, curve.p)) % curve.p;
        uint256 x3 = (s*s - x1 - x2) % curve.p;
        uint256 y3 = (s*(x1 - x3) - y1) % curve.p;

        return (s, x3, y3);
    }

function mul(EllipticCurve memory curve, uint256 x, uint256 y, uint256 scalar) internal view returns (uint256, uint256) {
    uint256 tx = x;
    uint256 ty = y;

    for (uint256 i = 0; i < 256; i++) {
        if ((scalar >> i) & 1 == 1) {
            (tx, ty) = add(curve, tx, ty, x, y);
        }

        (x, y) = add(curve, x, y, x, y);
    }

    return (tx, ty);
}

function inverseMod(uint256 a, uint256 m) private pure returns (uint256) {
    if (a == 0 || m <= 1) {
        revert("Curve: invalid arguments");
    }

    int256 t = 0;
    int256 newT = 1;
    uint256 r = m;
    int256 newR = int256(a);

    while (newR != 0) {
        int256 quotient = int256(r) / newR;

        (t, newT) = (newT, t - quotient * newT);
        (r, newR) = (uint256(newR), r - quotient * uint256(newR));
    }

    if (r > 1) {
        revert("Curve: not invertible");
    }

    if (t < 0) {
        t += int256(m);
    }

    return uint256(t);
}
