import React, { useState } from "react";
import {
  Grid,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  ListSubheader,
  Button,
  TextField
} from "@mui/material";
import PostAddIcon from "@mui/icons-material/PostAdd";
import UserActivityProposal from '../contracts/UserActivityProposal.json'

const ProposalList = ({contract, account, web3}, context) => {
    const [searchAccount, setSearchAccount] = useState(account);
    const [info, setInfo] = useState(null);

    const refreshList = async () => {
        if(searchAccount != null) {
            setInfo(null);
            const result = await contract.methods.userJoinedProposal(searchAccount).call({from: searchAccount});
            if(result && result.exists) {
                const proposalContract = new web3.eth.Contract(UserActivityProposal.abi, result.proposal);
                const acceptedCountsLimit = await proposalContract.methods.acceptedCountsLimit().call();
                const rejectCountsLimit = await proposalContract.methods.rejectCountsLimit().call();
                const user = await proposalContract.methods.user().call();
                const name = await proposalContract.methods.name().call();
                const amount = await proposalContract.methods.amount().call();
                const stage = await proposalContract.methods.stage().call();
                const managerAgreed = await proposalContract.methods.managerAgreed().call();
                const acceptedCounts = await proposalContract.methods.acceptedCounts().call();
                const rejectCounts = await proposalContract.methods.rejectCounts().call();
                console.log({
                    acceptedCountsLimit,
                    rejectCountsLimit,
                    user,
                    name,
                    amount,
                    stage,
                    managerAgreed,
                    acceptedCounts,
                    rejectCounts,
                    contract: proposalContract
                })

                setInfo({
                    acceptedCountsLimit,
                    rejectCountsLimit,
                    user,
                    name,
                    amount,
                    stage,
                    managerAgreed,
                    acceptedCounts,
                    rejectCounts,
                    contract: proposalContract
                })
            }  
        }
    }
    const agree = async () => {
        if(!searchAccount || !info) {
            return;
        }
        console.log(account, searchAccount);
        const result = await contract.methods.accept(searchAccount).send({ from: account});
        console.log(result);
    }

  return (
    <List subheader={
    <ListSubheader>
        用户加入申请状态
        <TextField size="small" style={{marginLeft: 10, marginRight: 10}} defaultValue={searchAccount} onChange={(e) => setSearchAccount(e.target.value)} /> 
        <Button onClick={refreshList}>查询</Button>
    </ListSubheader>
    }>
     { info && <ListItem>
        <ListItemIcon>
          <PostAddIcon />
        </ListItemIcon>
        <ListItemText>
            <Grid container >
                <Grid item xs={12}>
                    用户地址: {info.user}
                    <Button onClick={agree}> 
                        同意
                    </Button>
                </Grid>
                <Grid item xs={12}>
                    用户描述: {info.name}
                </Grid>
                <Grid item xs={6}>
                    用户申请金额: {info.amount}
                </Grid>
                <Grid item xs={6}>
                    提案状态: {info.stage}
                </Grid>
                <Grid item xs={4}>
                    维护者同意状态: {info.managerAgreed ? '已同意': '未操作'}
                </Grid>
                <Grid item xs={4}>
                    已同意用户数/需要同意用户数: {info.acceptedCounts} / {info.acceptedCountsLimit}
                </Grid>
                <Grid item xs={4}>
                    已拒绝用户数/需要拒绝用户数: {info.rejectCounts} / {info.rejectCountsLimit}
                </Grid>
            </Grid>
        </ListItemText>
      </ListItem> }
    </List>
  );
};

export default ProposalList;
