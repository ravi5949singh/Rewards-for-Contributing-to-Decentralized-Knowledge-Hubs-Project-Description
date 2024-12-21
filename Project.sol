// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KnowledgeRewards {
    address public owner;
    uint256 public totalRewardsDistributed;

    struct Contribution {
        address contributor;
        string contentHash; // IPFS or other decentralized storage hash
        uint256 reward;
        bool rewarded;
    }

    mapping(uint256 => Contribution) public contributions;
    uint256 public contributionCount;

    event ContributionSubmitted(uint256 indexed id, address indexed contributor, string contentHash);
    event RewardDistributed(uint256 indexed id, address indexed contributor, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function submitContribution(string memory _contentHash) public {
        contributions[contributionCount] = Contribution({
            contributor: msg.sender,
            contentHash: _contentHash,
            reward: 0,
            rewarded: false
        });

        emit ContributionSubmitted(contributionCount, msg.sender, _contentHash);
        contributionCount++;
    }

    function rewardContributor(uint256 _id, uint256 _rewardAmount) public onlyOwner {
        Contribution storage contribution = contributions[_id];

        require(!contribution.rewarded, "Reward already distributed for this contribution");

        contribution.reward = _rewardAmount;
        contribution.rewarded = true;

        (bool success, ) = contribution.contributor.call{value: _rewardAmount}("");
        require(success, "Failed to transfer reward");

        totalRewardsDistributed += _rewardAmount;

        emit RewardDistributed(_id, contribution.contributor, _rewardAmount);
    }

    receive() external payable {}

    function withdrawFunds(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
