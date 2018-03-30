module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
    networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
	  //from: "0x00420e910a57479076bdcb00e8314ed944ada311",
	  //gas: 3000000,
      network_id: "*" // Match any network id
    }
  }
};
