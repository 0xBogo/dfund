const HDWalletProvider = require("truffle-hdwallet-provider");
const INFURA_API_KEY = "9aa3d95b3bc440fa88ea12eaa4456161";
const MNEMONIC = "blush demand other tomorrow fun rival tip annual climb connect clip club"
const ropstenProvider = MNEMONIC
    ? new HDWalletProvider(
          MNEMONIC,
          `https://ropsten.infura.io/v3/${INFURA_API_KEY}`
      )
    : null;

module.exports = {
    /**
     * Networks define how you connect to your ethereum client and let you set the
     * defaults web3 uses to send transactions. If you don't specify one truffle
     * will spin up a development blockchain for you on port 9545 when you
     * run `develop` or `test`. You can ask a truffle command to use a specific
     * network from the command line, e.g
     *
     * $ truffle test --network <network-name>
     */

    networks: {
        // Useful for testing. The `development` name is special - truffle uses it by default
        // if it's defined here and no other network is specified at the command line.
        // You should run a client (like ganache-cli, geth or parity) in a separate terminal
        // tab if you use this network and you must also set the `host`, `port` and `network_id`
        // options below to some value.
        //
        development: {
            host: "127.0.0.1", // Localhost (default: none)
            port: 8545, // Standard Ethereum port (default: none)
            network_id: "*" // Any network (default: none)
        },
        ropsten: {
            networkCheckTimeout: 10000, 
            provider: ropstenProvider,
            gas: 8000000,
            gasPrice: 30000000000,
            from: "0xC2a5ea1d4406EC5fdd5eDFE0E13F59124C7e9803",
            network_id: 3,
            skipDryRun: false
        }
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.5.9", // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            settings: {
                // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200
                }
                // evmVersion: "petersburg"
            }
        }
    }
};
