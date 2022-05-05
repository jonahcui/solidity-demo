import { Button, Grid, Dialog, DialogTitle, DialogContent, DialogActions, TextField, DialogContentText } from "@mui/material";
import React, { useEffect, useState } from "react";

const UserInfo = ({
  contract,
  account,
  tokenContract,
  escrowTokenContract,
}) => {
  const [userInfo, setUserInfo] = useState({
    user: null,
    joined: false,
    info: "",
  });


  const [info, setInfo] = useState(null)
  const [amount, setAmount] = useState(0)
  const [balance, setBalance] = useState(0);
  const [balance2, setBalance2] = useState(0);

  const [totalSupply, setTotalSupply] = useState(0);
  const [totalSupply2, setTotalSupply2] = useState(0);

  const [openCreateProposal, setOpenCreateProposal] = useState(false);

  const loadData = async () => {
    const result = await contract.methods
      .userStates(account)
      .call({ from: account });
    setUserInfo(result);
    const totalSupply = await tokenContract.methods
      .totalSupply()
      .call({ from: account });
    setTotalSupply(totalSupply);
    const totalSupply2 = await escrowTokenContract.methods
      .totalSupply()
      .call({ from: account });
    setTotalSupply2(totalSupply2);
    const balance = await tokenContract.methods
      .balanceOf(account)
      .call({ from: account });
    setBalance(balance);
    const balance2 = await escrowTokenContract.methods
      .balanceOf(account)
      .call({ from: account });
    setBalance2(balance2);
  };

  useEffect(() => {
    loadData();
  });

  const join = async () => {
      contract.once("ProposalCreated", (result, error) => {
          if(!error) {
              console.log(result);
          }
      })
    const result = await contract.methods.join(amount, info).send({ from: account});
    setOpenCreateProposal(false)
  }

  return (
    <Grid container className="user-info">
      {!userInfo.joined && (
        <Grid item xs={12} style={{ marginBottom: 10 }}>
          您当前还未加入，是否要
          <Button onClick={() => setOpenCreateProposal(true)}>申请加入</Button>? **加入需要审核**
        </Grid>
      )}
      <Grid item xs={3}>
        当前Token: {balance}
      </Grid>
      <Grid item xs={3}>
        保险保证金: {balance2}
      </Grid>
      <Grid item xs={3}>
        总Token: {totalSupply}
      </Grid>
      <Grid item xs={3}>
        总保证金: {totalSupply2}
      </Grid>
      <Dialog open={openCreateProposal} onClose={() => setOpenCreateProposal(false)}>
        <DialogTitle>申请加入</DialogTitle>
        <DialogContent>
          <DialogContentText>
              加入需要合约维护者与用户共同审核
          </DialogContentText>
          <TextField
            autoFocus
            margin="dense"
            id="name"
            label="User Info"
            type="text"
            fullWidth
            variant="standard"
            onChange={(e) => setInfo(e.target.value)}
          />
          <TextField
            autoFocus
            margin="dense"
            id="amount"
            label="Price"
            type="number"
            fullWidth
            variant="standard"
            onChange={(e) => setAmount(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenCreateProposal(false)}>Cancel</Button>
          <Button onClick={join}>Join</Button>
        </DialogActions>
      </Dialog>
    </Grid>
  );
};

export default UserInfo;
