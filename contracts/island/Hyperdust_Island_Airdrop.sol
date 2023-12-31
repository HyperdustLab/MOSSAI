pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../utils/StrUtil.sol";
import "../MOSSAI_Roles_Cfg.sol";

abstract contract IMOSSAIIsland {
    function getIsland(
        uint256 islandId
    )
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            address,
            address,
            uint256,
            uint32,
            bytes32
        )
    {}
}

abstract contract IMOSSAIIslandNFG {
    function getSeedOwer(uint32 seed) public view returns (address) {}
}

contract Hyperdust_Island_Airdrop is Ownable {
    using Strings for *;
    using StrUtil for *;

    address public _MOSSAIRolesCfgAddress;
    address public _erc20Address;
    address public _MOSSAIIslandAddress;
    address public _MOSSAIIslandNFGAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _id;

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function setErc20Address(address erc20Address) public onlyOwner {
        _erc20Address = erc20Address;
    }

    function setMOSSAIIslandAddress(
        address MOSSAIIslandAddress
    ) public onlyOwner {
        _MOSSAIIslandAddress = MOSSAIIslandAddress;
    }

    function setMOSSAIIslandNFGAddress(
        address MOSSAIIslandNFGAddress
    ) public onlyOwner {
        _MOSSAIIslandNFGAddress = MOSSAIIslandNFGAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = contractaddressArray[0];
        _erc20Address = contractaddressArray[1];
        _MOSSAIIslandAddress = contractaddressArray[2];
        _MOSSAIIslandNFGAddress = contractaddressArray[3];
    }

    struct IslandAirdrop {
        uint256 id;
        string name;
        uint256 totalAmount;
        uint256 releaseAmount;
        uint256 minRandomAmount;
        uint256 maxRandomAmount;
        uint32 startTime;
        uint32 endTime;
        uint256 islandId;
        string airdropConfig;
        bytes1 status;
        address fromAddress;
        uint32 intervalTime;
    }

    IslandAirdrop[] public _islandAirdrops;
    mapping(address => uint256) _lastReleaseTimeMap;
    uint256 private _rand = 1;

    event eveSave(uint256 id);

    event eveDelete(uint256 id);

    event eveReceiveAirdrop(uint256 id, address to, uint256 amount);

    function addIslandAirdrop(
        string memory name,
        uint256[] memory uint256Array,
        uint32 startTime,
        uint32 endTime,
        string memory airdropConfig,
        bytes1 status,
        address fromAddress,
        uint32 intervalTime
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        _id.increment();

        if (uint256Array[3] != 0) {
            (uint256 id, , , , , , , , , ) = IMOSSAIIsland(_MOSSAIIslandAddress)
                .getIsland(uint256Array[3]);

            require(id > 0, "island not found");
        }

        _islandAirdrops.push(
            IslandAirdrop({
                id: _id.current(),
                name: name,
                totalAmount: uint256Array[0],
                releaseAmount: 0,
                minRandomAmount: uint256Array[1],
                maxRandomAmount: uint256Array[2],
                startTime: startTime,
                endTime: endTime,
                islandId: uint256Array[3],
                airdropConfig: airdropConfig,
                status: status,
                fromAddress: fromAddress,
                intervalTime: intervalTime
            })
        );

        emit eveSave(_id.current());
    }

    function updateIslandAirdrop(
        uint256 id,
        string memory name,
        uint256 minRandomAmount,
        uint256 maxRandomAmount,
        uint32 startTime,
        uint32 endTime,
        string memory airdropConfig,
        uint32 intervalTime,
        uint256 totalAmount,
        uint256 islandId
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        if (islandId != 0) {
            (uint256 id, , , , , , , , , ) = IMOSSAIIsland(_MOSSAIIslandAddress)
                .getIsland(islandId);

            require(id > 0, "island not found");
        }

        for (uint i = 0; i < _islandAirdrops.length; i++) {
            if (_islandAirdrops[i].id == id) {
                require(
                    _islandAirdrops[i].releaseAmount == 0,
                    "airdrop has release amount,Update is not allowed"
                );

                _islandAirdrops[i].minRandomAmount = minRandomAmount;
                _islandAirdrops[i].maxRandomAmount = maxRandomAmount;
                _islandAirdrops[i].startTime = startTime;
                _islandAirdrops[i].endTime = endTime;
                _islandAirdrops[i].airdropConfig = airdropConfig;
                _islandAirdrops[i].intervalTime = intervalTime;
                _islandAirdrops[i].name = name;
                _islandAirdrops[i].islandId = islandId;
                _islandAirdrops[i].totalAmount = totalAmount;
                emit eveSave(id);
                return;
            }
        }
        revert("not found");
    }

    function deleteIslandAirdrop(uint256 id) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );
        for (uint i = 0; i < _islandAirdrops.length; i++) {
            if (_islandAirdrops[i].id == id) {
                require(
                    _islandAirdrops[i].releaseAmount == 0,
                    "airdrop has release amount,Deletion is not allowed"
                );

                _islandAirdrops[i] = _islandAirdrops[
                    _islandAirdrops.length - 1
                ];
                _islandAirdrops.pop();
                emit eveDelete(id);

                return;
            }
        }
        revert("not found");
    }

    function updateStatus(uint256 id, bytes1 status) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );
        for (uint i = 0; i < _islandAirdrops.length; i++) {
            if (_islandAirdrops[i].id == id) {
                _islandAirdrops[i].status = status;
                emit eveSave(id);
                return;
            }
        }
        revert("not found");
    }

    function getIslandAirdrop(
        uint256 id
    )
        public
        view
        returns (
            uint256[] memory,
            uint32,
            uint32,
            string memory,
            bytes1,
            address,
            uint32,
            string memory name
        )
    {
        for (uint i = 0; i < _islandAirdrops.length; i++) {
            if (_islandAirdrops[i].id == id) {
                uint256[] memory uint256Array = new uint256[](6);
                uint256Array[0] = _islandAirdrops[i].id;
                uint256Array[1] = _islandAirdrops[i].totalAmount;
                uint256Array[2] = _islandAirdrops[i].releaseAmount;
                uint256Array[3] = _islandAirdrops[i].minRandomAmount;
                uint256Array[4] = _islandAirdrops[i].maxRandomAmount;
                uint256Array[5] = _islandAirdrops[i].islandId;

                return (
                    uint256Array,
                    _islandAirdrops[i].startTime,
                    _islandAirdrops[i].endTime,
                    _islandAirdrops[i].airdropConfig,
                    _islandAirdrops[i].status,
                    _islandAirdrops[i].fromAddress,
                    _islandAirdrops[i].intervalTime,
                    _islandAirdrops[i].name
                );
            }
        }
        revert("not found");
    }

    function getIslandAirdropObj(
        uint256 id
    ) public view returns (IslandAirdrop memory, uint256 index) {
        for (uint i = 0; i < _islandAirdrops.length; i++) {
            if (_islandAirdrops[i].id == id) {
                return (_islandAirdrops[i], i);
            }
        }
        revert("not found");
    }

    function receiveAirdrop(uint256 id) public {
        uint256 lastTime = _lastReleaseTimeMap[msg.sender];

        (
            IslandAirdrop memory islandAirdrop,
            uint256 index
        ) = getIslandAirdropObj(id);

        require(
            islandAirdrop.status == 0x01,
            "island airdrop status is not open"
        );

        uint256 timestamp = block.timestamp;
        require(
            timestamp >= islandAirdrop.startTime &&
                timestamp < islandAirdrop.endTime,
            "Temporary Closed"
        );

        require(
            timestamp - lastTime >= islandAirdrop.intervalTime,
            "Waiting for the next round drop."
        );

        uint256 randomAmount = _getRandom(
            islandAirdrop.minRandomAmount,
            islandAirdrop.maxRandomAmount
        );

        uint256 releaseAmount = islandAirdrop.releaseAmount + randomAmount;

        require(
            releaseAmount <= islandAirdrop.totalAmount,
            "This airdrop zone reached its limit."
        );

        uint256 allowance = IERC20(_erc20Address).allowance(
            islandAirdrop.fromAddress,
            address(this)
        );

        require(allowance >= randomAmount, "Insufficient authorized amount");

        IERC20(_erc20Address).transferFrom(
            islandAirdrop.fromAddress,
            msg.sender,
            randomAmount
        );

        _islandAirdrops[index].releaseAmount = releaseAmount;

        _lastReleaseTimeMap[msg.sender] = timestamp;

        emit eveReceiveAirdrop(id, msg.sender, randomAmount);

        emit eveSave(id);
    }

    function withdraw(uint256 id, uint256 amount) public {
        (
            IslandAirdrop memory islandAirdrop,
            uint256 index
        ) = getIslandAirdropObj(id);

        (, , , , , , , , uint32 seed, ) = IMOSSAIIsland(_MOSSAIIslandAddress)
            .getIsland(islandAirdrop.islandId);

        address seedOwer = IMOSSAIIslandNFG(_MOSSAIIslandNFGAddress)
            .getSeedOwer(seed);

        require(msg.sender == seedOwer, "not island ower");

        uint256 releaseAmount = islandAirdrop.releaseAmount + amount;

        require(
            releaseAmount <= islandAirdrop.totalAmount,
            "release amount is not enough"
        );

        uint256 allowance = IERC20(_erc20Address).allowance(
            islandAirdrop.fromAddress,
            address(this)
        );

        require(allowance >= amount, "Insufficient authorized amount");

        IERC20(_erc20Address).transferFrom(
            islandAirdrop.fromAddress,
            msg.sender,
            amount
        );

        _islandAirdrops[index].releaseAmount = releaseAmount;

        emit eveReceiveAirdrop(id, msg.sender, amount);

        emit eveSave(id);
    }

    /**
     * @dev Generates a random number between _start and _end (exclusive) using block difficulty, timestamp and a private variable _rand.
     * @param _start The start of the range (inclusive).
     * @param _end The end of the range (exclusive).
     * @return A random number between _start and _end (exclusive).
     */
    function _getRandom(
        uint256 _start,
        uint256 _end
    ) private returns (uint256) {
        if (_start == _end) {
            return _start;
        }
        uint256 _length = _end - _start;
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, _rand)
            )
        );
        random = (random % _length) + _start;
        _rand++;
        return random;
    }
}
