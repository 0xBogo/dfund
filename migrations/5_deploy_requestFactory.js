const TrustToken = artifacts.require("TrustToken");
const ProposalManagement = artifacts.require("ProposalManagement");
const RequestFactory = artifacts.require("RequestFactory");

module.exports = async deployer => {
    const trustToken = await TrustToken.deployed();
    const proposalManagement = await ProposalManagement.deployed();
    const temp = '0x' + Number(100000000000000000000).toString(16);
    await deployer.deploy(
        RequestFactory,
        trustToken.address,
        proposalManagement.address,
        "0x758A59cA2757df09fAea0e4b75a57A80475B2c8A",
        temp,
        1000
    );
};
