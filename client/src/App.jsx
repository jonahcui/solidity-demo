import React, { Component } from "react";
import MutualTokenFactory from "./contracts/MutualTokenFactory.json";
import MutualToken from "./contracts/MutualToken.json";
import MutualEscrowToken from "./contracts/MutualEscrowToken.json";
import getWeb3 from "./getWeb3";
import {
  Backdrop,
  CircularProgress,
  Button,
  Container,
  Alert,
  Divider,
} from "@mui/material";
import ProposalList from "./components/ProposalList";
import UserInfo from "./components/UserInfo";

import "./App.css";

class App extends Component {
  state = {
    storageValue: 0,
    web3: null,
    accounts: null,
    contract: null,
    tokenContract: null,
    escrowTokenContract: null,
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = MutualTokenFactory.networks[networkId];
      const instance = new web3.eth.Contract(
        MutualTokenFactory.abi,
        deployedNetwork && deployedNetwork.address
      );
      const owner = await instance.methods.owner().call({from: accounts[0]});
      console.log(owner);

      this.setState({ web3, accounts, contract: instance, owner });
      this.loadTokenContract(web3, accounts, instance);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.error(error);
    }
  };

  loadTokenContract = async (web3, accounts, contract) => {
    const tokenAddress = await contract.methods
      .getTokenAddress()
      .call({ from: accounts[0] });
    const tokenInstance = new web3.eth.Contract(MutualToken.abi, tokenAddress);
    const escrowTokenAddress = await contract.methods
      .getTokenAddress()
      .call({ from: accounts[0] });
    const escrowTokenInstance = new web3.eth.Contract(
      MutualEscrowToken.abi,
      escrowTokenAddress
    );

    this.setState({
      tokenContract: tokenInstance,
      escrowTokenContract: escrowTokenInstance,
    });
  };

  render() {
    if (!this.state.web3) {
      return (
        <Backdrop
          sx={{ color: "#fff", zIndex: (theme) => theme.zIndex.drawer + 1 }}
          open={true}
        >
          <CircularProgress color="inherit" />
        </Backdrop>
      );
    }
    return (
      <Container>
        <div className="App" style={{ marginTop: 20 }}>
          <Alert severity="success">
            Current Contract Address(合约账户地址):{" "}
            {this.state.contract ? this.state.contract._address : null},
            Owner: {this.state.owner}
          </Alert>
          <Divider />
          <Alert severity="warning">
            Current Account Address(用户账户地址):{" "}
            {this.state.accounts ? this.state.accounts[0] : null}
          </Alert>
          <Divider />
          {this.state.contract && this.state.tokenContract && (
            <UserInfo
              contract={this.state.contract}
              account={this.state.accounts[0]}
              tokenContract={this.state.tokenContract}
              escrowTokenContract={this.state.escrowTokenContract}
            />
          )}
          <Divider />
          {this.state.contract && (
            <ProposalList contract={this.state.contract}
              account={this.state.accounts[0]}
              web3={this.state.web3}
            />
          )}
        </div>
      </Container>
    );
  }
}

export default App;
