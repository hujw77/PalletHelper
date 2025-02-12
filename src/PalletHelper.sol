// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@darwinia/contracts-utils/contracts/Scale.sol";
import "@darwinia/contracts-utils/contracts/Input.sol";
import "@darwinia/contracts-utils/contracts/ScaleCodec.sol";

interface StateStorage {
    function state_storage(bytes memory storageKey) external view returns (bytes memory);
}

interface Hub {
    function getTopCollators(uint256 k) external view returns (address[] memory);
}

contract PalletHelper {
    using Scale for Input.Data;

    StateStorage constant STATE_STORAGE = StateStorage(0x0000000000000000000000000000000000000400);
    Hub constant HUB = Hub(0xa4fFAC7A5Da311D724eD47393848f694Baee7930);

    bytes constant ACTIVE_COLLATORS_KEY = hex"cec5070d609dd3497f72bde07fc96ba088dcde934c658227ee1dfafcd6e16903";
    bytes32 constant MIGRATION_START_TIME_KEY = hex"03a4971484692cd58fa781fd333a29706500b8b0f5e2d08ad46a290ff113be06";

    function getActiveCollatorCount() public view returns (uint256) {
        bytes memory count_value = STATE_STORAGE.state_storage(ACTIVE_COLLATORS_KEY);
        (uint256 count,) = ScaleCodec.decodeUintCompact(count_value);
        return count;
    }

    function getActiveCollators() public view returns (address[] memory) {
        bytes memory collators_value = STATE_STORAGE.state_storage(ACTIVE_COLLATORS_KEY);
        Input.Data memory data = Input.from(collators_value);
        uint32 count = data.decodeU32();
        address[] memory collators = new address[](count);
        for (uint256 i; i < count; i++) {
            collators[i] = data.decodeEthereumAddress();
        }
        return collators;
    }

    // Twox64Concat(AccountId20)
    function getSessionKey(bytes28 owner) public view returns (bytes32) {
        bytes memory storage_key =
            abi.encodePacked(hex"cec5070d609dd3497f72bde07fc96ba0", hex"4c014e6bf8b8c2c011e7290b85696bb3", owner);
        bytes memory session_key = STATE_STORAGE.state_storage(storage_key);
        return (session_key.length == 32) ? abi.decode(session_key, (bytes32)) : bytes32(0);
    }
}
