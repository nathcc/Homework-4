// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DynamicNFT
 * @dev A contract for creating dynamic non-fungible tokens (NFTs) with evolving rewards based on user loyalty points.
 */
contract DynamicNFT is ERC721 {
    mapping(address => uint256) public loyaltyPoints; // Mapping to store the loyalty points of each user
    mapping(address => bool) public authorizedCallers; // Mapping to track authorized callers
    address public owner; // Address of the contract owner
    uint256 public constant loyaltyThreshold = 1000; // Threshold for high loyalty points triggering special rewards

    event LoyaltyPointsUpdated(address indexed user, uint256 loyaltyPoints); // Event emitted when loyalty points are updated
    event NFTMinted(address indexed user, uint256 tokenId); // Event emitted when a new NFT is minted
    event RewardAction(address indexed user, string action); // Event emitted when a reward action is performed

    /**
     * @dev Constructor to initialize the contract with a name and symbol for the NFT.
     * @param _name The name of the NFT.
     * @param _symbol The symbol of the NFT.
     */
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
        authorizedCallers[msg.sender] = true;
    }

    /**
     * @dev Modifier to restrict access to only the contract owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /**
     * @dev Modifier to restrict access to authorized callers.
     */
    modifier onlyAuthorizedCaller() {
        require(authorizedCallers[msg.sender], "Caller is not authorized");
        _;
    }

    /**
     * @dev Mint a new NFT and assign it to the specified user.
     * @param _to The address of the user who will receive the NFT.
     */
    function mint(address _to) external onlyOwner {
        uint256 loyalty = loyaltyPoints[_to];
        uint256 tokenId = _generateTokenId(_to, loyalty);
        _mint(_to, tokenId);
        emit NFTMinted(_to, tokenId);
    }

    /**
     * @dev Perform a reward action for the specified user based on their loyalty points.
     * @param _user The address of the user to perform the reward action for.
     */
    function rewardAction(address _user) external onlyOwner {
        uint256 loyalty = loyaltyPoints[_user];
        if (loyalty >= loyaltyThreshold) {
            emit RewardAction(_user, "Access to exclusive party granted!");
        } else {
            emit RewardAction(_user, "Received additional tokens!");
        }
    }

    /**
     * @dev Update the loyalty points for a user.
     * @param _user The address of the user whose loyalty points will be updated.
     * @param _points The number of loyalty points to add.
     */
    function updateLoyaltyPoints(address _user, uint256 _points) external onlyAuthorizedCaller {
        loyaltyPoints[_user] += _points;
        emit LoyaltyPointsUpdated(_user, loyaltyPoints[_user]);
    }

    /**
     * @dev Authorize or revoke an address to perform certain actions.
     * @param _caller The address to authorize or revoke.
     * @param _status The authorization status (true for authorized, false for unauthorized).
     */
    function setAuthorizedCaller(address _caller, bool _status) external onlyOwner {
        authorizedCallers[_caller] = _status;
    }

    /**
     * @dev Internal function to generate a unique token ID based on user address and loyalty points.
     * @param _user The address of the user.
     * @param _loyalty The loyalty points of the user.
     * @return uint256 The generated token ID.
     */
    function _generateTokenId(address _user, uint256 _loyalty) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_user, _loyalty)));
    }
}
