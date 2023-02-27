pragma solidity ^0.8.0;

library Hashing {
    function sha256(bytes memory message) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(message));
    }

    function sha256(bytes memory message, bytes memory extraData) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(message, extraData));
    }

    function sha256(bytes memory packedData) private pure returns (bytes32) {
        return bytes32(sha256hash(packedData));
    }

    function sha256hash(bytes memory packedData) private pure returns (bytes memory) {
        return abi.encodePacked(sha256(abi.encodePacked(packedData)));
    }
}
