// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ITransactionCfg {
    function get(string memory func) public view returns (uint256) {}
}

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}
}

abstract contract IIslandAssetsCfg {
    function getAddressConfList()
        public
        view
        returns (
            address _transactionCfgAddress,
            address _erc20Address,
            address _walletAccountAddres,
            address _rolesCfgAddress
        )
    {}
}

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
}

contract Island_721 is
    ERC721,
    ERC721URIStorage,
    ERC721Burnable,
    AccessControl,
    Ownable
{
    using Counters for Counters.Counter;

    using Strings for *;

    address public _islandAssetsCfgAddress;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor(address islandAssetsCfgAddress) ERC721("Island_721", "island") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _islandAssetsCfgAddress = islandAssetsCfgAddress;
    }

    function safeMint(
        address to,
        string memory uri
    ) public onlyRole(MINTER_ROLE) {
        (
            address _transactionCfgAddress,
            address _erc20Address,
            address _walletAccountAddres,
            address _rolesCfgAddress
        ) = IIslandAssetsCfg(_islandAssetsCfgAddress).getAddressConfList();

        ITransactionCfg transactionCfg = ITransactionCfg(
            _transactionCfgAddress
        );

        IERC20 erc20 = IERC20(_erc20Address);

        uint256 amount = erc20.allowance(msg.sender, address(this));

        uint256 mintNFTAmount = IHyperdustTransactionCfg(_transactionCfgAddress)
            .getGasFee("mintNFT");

        require(amount >= mintNFTAmount, "Insufficient authorized amount");

        erc20.transferFrom(msg.sender, _walletAccountAddres, mintNFTAmount);

        IWalletAccount walletAccountAddress = IWalletAccount(
            _walletAccountAddres
        );

        walletAccountAddress.addAmount(mintNFTAmount);

        uint256 tokenId = _tokenIdCounter.current() + 1;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
