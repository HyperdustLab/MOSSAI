pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "./MOSSAI_Island_Map.sol";
import "../Hyperdust_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";
import "./MOSSAI_Island_NFG.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "../utils/StrUtil.sol";

abstract contract IIslandFactory {
    function deploy(
        address account,
        string memory name,
        string memory symbol
    ) public returns (address) {}
}

abstract contract IHyperdustSpaceAddress {
    function add(
        string memory name,
        string memory coverImage,
        string memory image,
        string memory remark
    ) public returns (bytes32) {}

    function edit(
        bytes32 sid,
        string memory name,
        string memory coverImage,
        string memory image,
        string memory remark
    ) public {}
}

contract MOSSAI_Island is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _islandNFGAddress;
    address public _MOSSAIIslandMapAddress;
    address public _island721FactoryAddress;
    address public _island1155FactoryAddress;
    address public _HyperdustRolesCfgAddress;
    address public _MOSSAIStorageAddress;
    address public _IslandMintAddress;
    address public _HyperdustSpaceAddress;

    string public defCoverImage;
    string public defFile;
    string public fileHash;

    uint256 public _erc721Version;
    uint256 public _erc1155Version;

    event eveSaveIsland(bytes32 sid);

    event eveErc721Version();
    event eveErc1155Version();

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setDefParameter(
        string memory _defCoverImage,
        string memory _defFile,
        string memory _fileHash
    ) public onlyOwner {
        defCoverImage = _defCoverImage;
        defFile = _defFile;
        fileHash = _fileHash;
    }

    function setIslandNFGAddress(address islandNFGAddress) public onlyOwner {
        _islandNFGAddress = islandNFGAddress;
    }

    function setMOSSAIIslandMapAddress(
        address MOSSAIIslandMapAddress
    ) public onlyOwner {
        _MOSSAIIslandMapAddress = MOSSAIIslandMapAddress;
    }

    function setIsland721FactoryAddress(
        address island721FactoryAddress
    ) public onlyOwner {
        _island721FactoryAddress = island721FactoryAddress;
    }

    function setIsland1155FactoryAddress(
        address island1155FactoryAddress
    ) public onlyOwner {
        _island1155FactoryAddress = island1155FactoryAddress;
    }

    function setHyperdustRolesCfgAddress(
        address HyperdustRolesCfgAddress
    ) public onlyOwner {
        _HyperdustRolesCfgAddress = HyperdustRolesCfgAddress;
    }

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    function setIslandMintAddress(address IslandMintAddress) public onlyOwner {
        _IslandMintAddress = IslandMintAddress;
    }

    function setHyperdustSpaceAddress(
        address HyperdustSpaceAddress
    ) public onlyOwner {
        _HyperdustSpaceAddress = HyperdustSpaceAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _islandNFGAddress = contractaddressArray[0];
        _MOSSAIIslandMapAddress = contractaddressArray[1];
        _island721FactoryAddress = contractaddressArray[2];
        _island1155FactoryAddress = contractaddressArray[3];
        _HyperdustRolesCfgAddress = contractaddressArray[4];
        _MOSSAIStorageAddress = contractaddressArray[5];
        _IslandMintAddress = contractaddressArray[6];
        _HyperdustSpaceAddress = contractaddressArray[7];
    }

    function mint(
        uint32 coordinate,
        address owner,
        string memory islandName,
        string[] memory names,
        string[] memory symbols
    ) public {
        require(
            Hyperdust_Roles_Cfg(_HyperdustRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        IHyperdustSpaceAddress hyperdustSpaceAddress = IHyperdustSpaceAddress(
            _HyperdustSpaceAddress
        );

        string memory key = string(
            abi.encodePacked("coordinate_", coordinate.toString())
        );

        require(
            !mossaiStorage.getBool(key),
            coordinate.toString().toSlice().concat(
                " coordinate already exists".toSlice()
            )
        );

        mossaiStorage.setBool(key, true);

        MOSSAI_Island_Map(_MOSSAIIslandMapAddress).updateMintStatus(
            coordinate,
            true
        );

        uint256 seed = MOSSAI_Island_NFG(_islandNFGAddress).mint(
            owner,
            coordinate
        );

        address island721Address = IIslandFactory(_island721FactoryAddress)
            .deploy(_IslandMintAddress, names[0], symbols[0]);

        address island1155Address = IIslandFactory(_island1155FactoryAddress)
            .deploy(_IslandMintAddress, names[1], symbols[1]);

        uint256 id = mossaiStorage.getNextId();

        bytes32 sid = hyperdustSpaceAddress.add(
            islandName,
            defCoverImage,
            "",
            ""
        );
        mossaiStorage.setBytes32Uint(sid, id);

        mossaiStorage.setString(mossaiStorage.genKey("name", id), islandName);

        mossaiStorage.setString(
            mossaiStorage.genKey("coverImage", id),
            defCoverImage
        );

        mossaiStorage.setString(mossaiStorage.genKey("file", id), defFile);
        mossaiStorage.setString(mossaiStorage.genKey("fileHash", id), fileHash);

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc721Address", id),
            island721Address
        );

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc1155Address", id),
            island1155Address
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("coordinate", id),
            coordinate
        );

        mossaiStorage.setUint(mossaiStorage.genKey("seed", id), seed);
        mossaiStorage.setBytes32(mossaiStorage.genKey("sid", id), sid);

        mossaiStorage.setUint(
            mossaiStorage.genKey("erc721Version", id),
            _erc721Version
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("erc1155Version", id),
            _erc1155Version
        );

        emit eveSaveIsland(sid);
    }

    function updateErc721Address(
        bytes32 sid,
        string memory name,
        string memory symbol
    ) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 id = mossaiStorage.getBytes32Uint(sid);

        require(id > 0, "not found");

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );
        require(bytes(_name).length > 0, "not found");

        uint256 seed = mossaiStorage.getUint(mossaiStorage.genKey("seed", id));

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(
            uint32(seed)
        );

        require(owner == msg.sender, "not owner");

        address erc721Address = IIslandFactory(_island721FactoryAddress).deploy(
            _IslandMintAddress,
            name,
            symbol
        );

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc721Address", id),
            erc721Address
        );
        mossaiStorage.setUint(
            mossaiStorage.genKey("erc721Version", id),
            _erc721Version
        );

        emit eveSaveIsland(sid);
    }

    function updateErc1155Address(
        bytes32 sid,
        string memory name,
        string memory symbol
    ) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 id = mossaiStorage.getBytes32Uint(sid);

        require(id > 0, "not found");

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );
        require(bytes(_name).length > 0, "not found");

        uint256 seed = mossaiStorage.getUint(mossaiStorage.genKey("seed", id));

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(
            uint32(seed)
        );

        require(owner == msg.sender, "not owner");

        address erc1155Address = IIslandFactory(_island1155FactoryAddress)
            .deploy(_IslandMintAddress, name, symbol);

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc1155Address", id),
            erc1155Address
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("erc1155Version", id),
            _erc1155Version
        );
        emit eveSaveIsland(sid);
    }

    function update(
        bytes32 sid,
        string memory name,
        string memory coverImage,
        string memory file,
        string memory fileHash,
        string memory scenesData,
        string memory placementRecord
    ) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 id = mossaiStorage.getBytes32Uint(sid);
        require(id > 0, "not found");

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        uint256 seed = mossaiStorage.getUint(mossaiStorage.genKey("seed", id));

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(
            uint32(seed)
        );

        require(owner == msg.sender, "not owner");

        mossaiStorage.setString(mossaiStorage.genKey("name", id), name);
        mossaiStorage.setString(
            mossaiStorage.genKey("coverImage", id),
            coverImage
        );

        mossaiStorage.setString(mossaiStorage.genKey("file", id), file);
        mossaiStorage.setString(mossaiStorage.genKey("fileHash", id), fileHash);
        mossaiStorage.setString(
            mossaiStorage.genKey("scenesData", id),
            scenesData
        );

        mossaiStorage.setString(
            mossaiStorage.genKey("placementRecord", id),
            placementRecord
        );

        IHyperdustSpaceAddress hyperdustSpaceAddress = IHyperdustSpaceAddress(
            _HyperdustSpaceAddress
        );

        hyperdustSpaceAddress.edit(sid, name, coverImage, "", "");

        emit eveSaveIsland(sid);
    }

    function getIsland(
        bytes32 sid
    )
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            address,
            address,
            uint256,
            uint256,
            bytes32,
            string memory,
            string memory,
            uint256,
            uint256
        )
    {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 islandId = mossaiStorage.getBytes32Uint(sid);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", islandId)
        );

        require(bytes(_name).length > 0, "not found");

        return (
            _name,
            mossaiStorage.getString(
                mossaiStorage.genKey("coverImage", islandId)
            ),
            mossaiStorage.getString(mossaiStorage.genKey("file", islandId)),
            mossaiStorage.getString(mossaiStorage.genKey("fileHash", islandId)),
            mossaiStorage.getAddress(
                mossaiStorage.genKey("erc721Address", islandId)
            ),
            mossaiStorage.getAddress(
                mossaiStorage.genKey("erc1155Address", islandId)
            ),
            mossaiStorage.getUint(mossaiStorage.genKey("coordinate", islandId)),
            mossaiStorage.getUint(mossaiStorage.genKey("seed", islandId)),
            mossaiStorage.getBytes32(mossaiStorage.genKey("sid", islandId)),
            mossaiStorage.getString(
                mossaiStorage.genKey("scenesData", islandId)
            ),
            mossaiStorage.getString(
                mossaiStorage.genKey("placementRecord", islandId)
            ),
            mossaiStorage.getUint(
                mossaiStorage.genKey("erc721Version", islandId)
            ),
            mossaiStorage.getUint(
                mossaiStorage.genKey("erc1155Version", islandId)
            )
        );
    }

    function updateErc721Version(uint256 version) public {
        require(
            Hyperdust_Roles_Cfg(_HyperdustRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );
        _erc721Version = version;
        emit eveErc721Version();
    }

    function updateErc1155Version(uint256 version) public {
        require(
            Hyperdust_Roles_Cfg(_HyperdustRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );
        _erc1155Version = version;

        emit eveErc1155Version();
    }

    function getVersions() public view returns (uint256, uint256) {
        return (_erc721Version, _erc1155Version);
    }
}
