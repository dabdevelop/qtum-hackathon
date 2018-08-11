module.exports = {
  networks: {
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "4",
      gas: 4500000,
      gasPrice: 50000000000
    },

    testnet: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 4500000,
      gasPrice: 20000000000
    },

    live: {
      host: "localhost",
      port: 8545,
      network_id: 1,
      gas: 4500000,
      gasPrice: 20000000000
    },

    dev: {
      host: "localhost",
      port: 8545,
      network_id: "1",
      gas: 4500000,
      gasPrice: 20000000000
    },

    testrpc: {
      host: "localhost",
      port: 8545,
      network_id: 10,
      gas: 4500000,
      gasPrice: 24000000000
    }
  }
};
