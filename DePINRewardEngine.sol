// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DePINRewardEngine is Ownable {
    struct Device {
        address operator;
        uint256 lastHeartbeat;
        uint256 totalEarned;
        bool active;
    }

    mapping(bytes32 => Device) public devices;
    uint256 public rewardPerEpoch = 10 * 1e18; // 10 Tokens

    event HeartbeatReceived(bytes32 indexed deviceId, address indexed operator);
    event RewardDistributed(bytes32 indexed deviceId, uint256 amount);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Proof-of-Physical-Work heartbeat sent by verified hardware.
     */
    function recordHeartbeat(bytes32 _deviceId) external {
        require(devices[_deviceId].active, "Device not registered");
        
        devices[_deviceId].lastHeartbeat = block.timestamp;
        emit HeartbeatReceived(_deviceId, msg.sender);
    }

    function distributeRewards(bytes32 _deviceId) external onlyOwner {
        require(block.timestamp - devices[_deviceId].lastHeartbeat < 1 days, "Offline");
        
        uint256 reward = rewardPerEpoch;
        devices[_deviceId].totalEarned += reward;
        
        emit RewardDistributed(_deviceId, reward);
    }
}
