var MutualTokenFactory = artifacts.require("./MutualTokenFactory.sol");

contract("MutualTokenFactory", accounts => {

    it("should create proposal", async () => {
        const mutualTokenFactory = await MutualTokenFactory.deployed({
            from: accounts[0]
        });

        const result = await mutualTokenFactory.join(1000, "test", {from: accounts[1]});
    })
})