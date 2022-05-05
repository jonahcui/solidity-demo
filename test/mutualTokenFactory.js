var MutualTokenFactory = artifacts.require("./MutualTokenFactory.sol");

contract("MutualTokenFactory", accounts => {

    it("should create proposal by special owner", async () => {
        const mutualTokenFactory = await MutualTokenFactory.deployed({
            from: accounts[0]
        });

        const owner = await mutualTokenFactory.owner.call();

        assert.equal(accounts[0], owner);
    })


    it("should create user proposal when join given a not joined user", async () => {
        const mutualTokenFactory = await MutualTokenFactory.deployed({
            from: accounts[0]
        });

        const result = await mutualTokenFactory.join(1000, "test", {from: accounts[1]});
        const userProposal = await mutualTokenFactory.userJoinedProposal.call(accounts[1]);

        assert.isNotNull(result);
        assert.equal(true, userProposal.exists)
    }) 
})