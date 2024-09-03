// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {PalletHelper} from "../src/PalletHelper.sol";

contract Deploy is Script {

    address immutable CREATE2_ADDR = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() public broadcast {
        bytes memory code = type(PalletHelper).creationCode;
		_deploy2(bytes32(0), code);
	}

    function _deploy2(bytes32 salt, bytes memory initCode) internal returns (address) {
        if (CREATE2_ADDR.code.length == 0) revert("CREATE2FactoryNotDeployed");
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = CREATE2_ADDR.call(data);
        return address(uint160(bytes20(addr)));
    }
}
