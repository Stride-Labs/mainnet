# PoolParty Bounty Tasks [Deprecated]

NOTE: PoolParty has ended, so you can no longer earn incentivized testnet rewards. This page is kept for historical purposes.

To earn rewards on the PoolParty testnet, submit evidence of having completed the following tasks. The goal is stress test the Stride core appchain and module logic. 

**Thoughtful, clear submissions will be rewarded ***far*** more than low-effort submissions, which will receive minimal rewards. You do NOT need to make a submission to earn rewards for running validators and relayers. We will detect your validators and relayers using onchain data.**


### Disclaimers
1. We will NOT verify your submission is valid until the incentivized testnet has finished.
2. The points listed in the task are the max you can earn for completing the task with high quality. Most submissions will earn fewer points for low quality, or no points if they violate the rules.
3. You will be asked to prove you own the address associated with the account that completed the task
4. You will be asked for several other verifications to prevent sybil attacks. 
5. Most tasks can only be completed once. Use your judgement (e.g. we will NOT reward you for delegating twice)
## How To Submit A Task
Please submit evidence you've completed a task using this [Mission/Appeals Submission](https://forms.gle/KG9vKb5fknqGYQRu9).

Use your best judgement to determine what constitutes proof you've completed the task (links to transactions/accounts and writeups are best; screenshots are acceptable but not ideal, other forms of evidence are unlikely to earn you rewards).  

### Questions?
Questions about incentivized testnet are ONLY allowed in the **#testnet-tasks** channel. **If you ask questions in other channels, you risk losing your incentives.**


## 🗡️ Adversarial Tasks
| # | Pts |  Task  | Evidence |
| -- | -- | ------------- |:-------------:|
| **1** | 750 | find a non-trivial bug in [stride's core repo](https://github.com/Stride-Labs/stride) (must be in the `x/ directory` or `app.go`) | writeup and link to the code (bonus points if you submit a PR to fix it!)|| **5** | 100 | spam network with transactions | writeup on your results and link to the blocks you spammed |
| **2** | 750 | cause the chain to halt through normal usage of the network | writeup and link to your address |
| **3** | 1000 | steal user testnet funds (any attack approach is allowed!) | writeup and link to transactions involved |


## 📚 Community Tasks
| # | Pts |  Task  | Evidence |
| -- | -- | ------------- |:-------------:|
| **4** | 50 | resolve over 20 users questions in discord (high quality answers only) | your discord handle and link to a few of the messages  |
| **5** | 200 | contribute to creating the stride support lab (message samuel on Discord to begin) | submit writeup on your contributions |

## 🌊 Product Tasks
| # | Pts |  Task  | Evidence |
| -- | -- | ------------- |:-------------:|
| **6** | 50 | complete the stake, redeem, and claim flow (including 6hr unbonding) | link to all the txs: liqstake, redeem, claim |

## 🛰  Relayer Tasks 

| # | Pts |  Task  | Evidence |
| -- | -- | ------------- |:-------------:|
| **7** | 100 | run a relayer on ICA channels specified in #validator-announcements for at least 7 days | No Evidence Needed. |
| **8** | 250 | relay using the new [v2 go relayer](https://github.com/cosmos/relayer/releases/tag/v2.0.0-rc4)      | link to packets relayed and link to the configured relayer fork on your github |
| **9** | 750 | relay interchain queries using the new [v2 go relayer](https://github.com/cosmos/relayer/releases/tag/v2.0.0-rc4) | link to ICQ packets relayed and link to the configured relayer fork on your github |

## ⚡ Validator Tasks 

| # | Pts |  Task  | Evidence |
| -- | -- | ------------- |:-------------:|
| **10** | 100 | run validator for at least 7 days (being inactive is OK, it still qualifies) | No Evidence Needed. |
| **11** | 10 | delegate to another validator  | link to the delegation transaction |
