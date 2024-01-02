// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YupLiveAccess is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {

    address erc20TokenAddres;
    uint256 erc20AccessAmount;

    event AccessAdded(string email, string accessHash);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialOwner, address _initToken, uint256 _initerc20AccessAmount) public initializer {
        
        erc20TokenAddres = _initToken;
        erc20AccessAmount = _initerc20AccessAmount;
        
        __Pausable_init();
        __Ownable_init(_initialOwner);
        __UUPSUpgradeable_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function isValidHash(string memory str) private pure returns (bool) {
        bytes memory b = bytes(str);
        if (b.length != 64) return false;
        for (uint i = 0; i < b.length; i++) {
            bytes1 char = b[i];
            if (!(char >= 0x30 && char <= 0x39) && !(char >= 0x61 && char <= 0x66)) {
                return false;
            }
        }
        return true;
    }
    

    function addAccess (string memory email, string memory accessHash) public {
        require(bytes(email).length > 0, "Email cannot be empty");
        require(bytes(accessHash).length > 0, "Access hash cannot be empty");
        require(isValidHash(accessHash), "Access hash is not valid");
        ERC20 token = ERC20(erc20TokenAddres);
        uint256 balance = token.balanceOf(msg.sender);
        require(balance >= erc20AccessAmount, "Not enough tokens to execute transaction");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= erc20AccessAmount, "Not enough allowance to execute transaction");

        token.transferFrom(msg.sender, address(this), erc20AccessAmount);

        emit AccessAdded(email, accessHash);
    }

    function getAccessAmount() public view returns (uint256) {
        return erc20AccessAmount;
    }

    function setAccessAmount(uint256 newAccessAmount) public onlyOwner {
        erc20AccessAmount = newAccessAmount;
    }

    function setContractToken(address newTokenAddress) public onlyOwner {
        erc20TokenAddres = newTokenAddress;
    }

    function getContractToken() public view returns (address) {
        return erc20TokenAddres;
    }

    function setOwner(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    function setIntialState(address _initialOwner, address _initToken, uint256 _initerc20AccessAmount) public onlyOwner {
        transferOwnership(_initialOwner);
        erc20TokenAddres = _initToken;
        erc20AccessAmount = _initerc20AccessAmount;
    }

    function transferTokens(address tokenAddress, address to, uint256 amount) public onlyOwner {
        ERC20(tokenAddress).transfer(to, amount);
    }

    function withdrawTokens(address tokenAddress, uint256 amount) public onlyOwner {
        ERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function withdrawNative(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }
}