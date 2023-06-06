// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IWhitelist {
    //basically this function checks if the given address is present in the whitelist or not.abi
    function whitelistedAddresses(address) external view returns (bool);
}