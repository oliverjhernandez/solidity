pragma solidity ^0.4.25;

contract Proxy {
    function() external payable {
        _fallback();
    }

    function _implementation() internal view returns (address);

    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := delegatecall(
                gas,
                implementation,
                0,
                calldatasize,
                0,
                0
            )

            returndatacopy(0, 0, returndatasize)

            switch result
            case 0 {
                revert(0, returndatasize)
            }
            default {
                return(0, returndatasize)
            }
        }
    }

    function _willFallback() internal {}

    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

library AddressUtils {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

contract UpgradeabilityProxy is Proxy {
    event Upgraded(address implementation);

    bytes32 private constant IMPLEMENTATION_SLOT =
        0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

    constructor(address _implementation) public {
        assert(
            IMPLEMENTATION_SLOT ==
                keccak256("org.zeppelinos.proxy.implementation")
        );

        _setImplementation(_implementation);
    }

    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {
        require(
            AddressUtils.isContract(newImplementation),
            "Cannot set a proxy implementation to a non-contract address"
        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant ADMIN_SLOT =
        0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    constructor(address _implementation)
        public
        UpgradeabilityProxy(_implementation)
    {
        assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));

        _setAdmin(msg.sender);
    }

    function admin() external view ifAdmin returns (address) {
        return _admin();
    }

    function implementation() external view ifAdmin returns (address) {
        return _implementation();
    }

    function changeAdmin(address newAdmin) external ifAdmin {
        require(
            newAdmin != address(0),
            "Cannot change the admin of a proxy to the zero address"
        );
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes data)
        external
        payable
        ifAdmin
    {
        _upgradeTo(newImplementation);
        require(address(this).call.value(msg.value)(data));
    }

    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _willFallback() internal {
        require(
            msg.sender != _admin(),
            "Cannot call fallback function from the proxy admin"
        );
        super._willFallback();
    }
}

pragma solidity ^0.4.25;

contract FiatTokenProxy is AdminUpgradeabilityProxy {
    constructor(address _implementation)
        public
        AdminUpgradeabilityProxy(_implementation)
    {}
}

pragma solidity ^0.4.25;

contract MyContract {
    function getCurrentImplementation() external view returns (address) {
        return
            MyProxyContract(0x07865c6e87b9f70255377e024ace6630c1eaa37f)
                .implementation();
    }
}

interface MyProxyContract {
    function implementation() external view returns (address);
}

/*
Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Migrations dry-run (simulation)
===============================
> Network name:    'sepolia-fork'
> Network id:      11155111
> Block gas limit: 30000000 (0x1c9c380)


1_deploy_contract.js
====================

   Deploying 'Inbox'
   -----------------
   > block number:        3379733
   > block timestamp:     1682701735
   > account:             0x8872Bb5a0aD81a76AE2e0C84CD5491a22E84682C
   > balance:             0.997530409993085148
   > gas used:            493918 (0x7895e)
   > gas price:           2.500000007 gwei
   > value sent:          0 ETH
   > total cost:          0.001234795003457426 ETH

   -------------------------------------
   > Total cost:     0.001234795003457426 ETH

Summary
=======
> Total deployments:   1
> Final cost:          0.001234795003457426 ETH




Starting migrations...
======================
> Network name:    'sepolia'
> Network id:      11155111
> Block gas limit: 30000000 (0x1c9c380)


1_deploy_contract.js
====================

   Deploying 'Inbox'
   -----------------
   > transaction hash:    0x3c3f601faad4b91778436b95164a0a7d98e92df1cff5b1a9a524ae1987f55184
   > Blocks: 0            Seconds: 0
   > contract address:    0x99bfCf07CdC3dd6C34aCcd9513132d6D0b0B4783
   > block number:        3379737
   > block timestamp:     1682701740
   > account:             0x8872Bb5a0aD81a76AE2e0C84CD5491a22E84682C
   > balance:             0.997530409993085148
   > gas used:            493918 (0x7895e)
   > gas price:           2.500000007 gwei
   > value sent:          0 ETH
   > total cost:          0.001234795003457426 ETH

   > Saving artifacts
   -------------------------------------
   > Total cost:     0.001234795003457426 ETH

Summary
=======
> Total deployments:   1
> Final cost:          0.001234795003457426 ETH
*/
