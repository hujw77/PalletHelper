// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@darwinia/contracts-utils/contracts/Bytes.sol";

interface StateStorage {
    function state_storage(bytes memory storageKey) external view returns (bytes memory);
}

contract PalletHelper {
    StateStorage constant STATE_STORAGE = StateStorage(0x0000000000000000000000000000000000000400);

    bytes constant COLLATOR_COUNT_KEY = hex"03a4971484692cd58fa781fd333a29702bf10f943ea01b83e17db9b4b2ab031a";
    bytes32 constant MIGRATION_START_TIME_KEY = hex"03a4971484692cd58fa781fd333a29706500b8b0f5e2d08ad46a290ff113be06";

    function getContractCollators() public view returns (uint256) {
        bytes memory count_value = STATE_STORAGE.state_storage(COLLATOR_COUNT_KEY);
        uint32 count = decodeUint32(count_value);

        bytes memory migration_start_time_value =
            STATE_STORAGE.state_storage(abi.encodePacked(MIGRATION_START_TIME_KEY));
        uint128 migration_start_time = decodeUint128(migration_start_time_value);

        uint256 diff = (block.timestamp - uint256(migration_start_time) / 1000) * 100 / 60 days;
        return (diff >= 100) ? count : diff * count / 100;
    }

    // Twox64Concat(AccountId20)
    function getSessionKey(bytes28 owner) public view returns (bytes32) {
        bytes memory storageKey =
            abi.encodePacked(hex"cec5070d609dd3497f72bde07fc96ba0", hex"4c014e6bf8b8c2c011e7290b85696bb3", owner);
        return abi.decode(STATE_STORAGE.state_storage(storageKey), (bytes32));
    }

    function decodeUint32(bytes memory data) internal pure returns (uint32) {
        require(data.length == 4, "Bad data");
        bytes memory reversed = Bytes.reverse(data);
        return uint32(Bytes.toBytes4(reversed, 0));
    }

    function decodeUint128(bytes memory data) internal pure returns (uint128) {
        if (data.length == 0) return 0;
        require(data.length == 16, "Bad data");
        bytes memory reversed = Bytes.reverse(data);
        return uint128(Bytes.toBytes16(reversed, 0));
    }
}
