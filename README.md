# How to set up an Ethereum PoS private network

## clients
After the Merge, running a Ethereum node requires two clients:

1. execution client, in charge of processing transactions and smart contracts.
2. consensus client, in charge of running the proof-of-stack logic.

In this guide, we are going to use Geth and Prysm.

## configuration 

### explanation for genesis.json

#### 1. validator deposit contract
```json
    "4242424242424242424242424242424242424242": {
        "code": "0x6080.....",
        "balance": "0x0"
    },

```
This field deploys a validator deposit contract

#### 2. accounts with ETHs from the genesis block

```json
 "123463a4b065722e99115d6c222f267d9cabb524": {
        "balance": "0x43c33c1937564800000"
    },
```

#### 3. ShanghaiTime

```json
"config": {
    ...
    "shanghaiTime": 1694203366,
    ...
}
```

It indicates when the Shanghai update should occur. This corresponds to Friday 8 September 2023 08:02:46 PM, which is already into the past.


#### 4. timestamp

```json
"timestamp": "0x64fb7de6",
```

which corresponds to 1694203366, and which defines the genesis time of the chain. The fact that timestamp is equal to config.shanghaiTime tells that the chain will start directly at the time of the Shanghai upgrade.


## prysm

```shell
./prysmctl testnet generate-genesis --fork capella --num-validators 64 --genesis-time-delay 600 --chain-config-file config.yml --geth-genesis-json-in genesis.json  --geth-genesis-json-out genesis.json --output-ssz genesis.ssz

```


## run execution client


```shell
./geth --datadir=gethdata init genesis.json
```

```shell
./geth --http --http.api eth,net,web3 --ws --ws.api eth,net,web3 --authrpc.jwtsecret jwt.hex --datadir gethdata --nodiscover --syncmode full --allow-insecure-unlock --unlock 0x123463a4b065722e99115d6c222f267d9cabb524
```


## run consensus client

```shell
./beacon-chain --datadir=./beacondata --min-sync-peers=0 --genesis-state=genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file=config.yml --contract-deployment-block=0 --chain-id=32382 --rpc-host=0.0.0.0 --grpc-gateway-host=0.0.0.0 --execution-endpoint=http://localhost:8551 --accept-terms-of-use --jwt-secret=jwt.hex --suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 --minimum-peers-per-subnet=0 --enable-debug-rpc-endpoints --force-clear-db

./beacon-chain --datadir beacondata --min-sync-peers 0 --genesis-state genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file config.yml --contract-deployment-block 0 --chain-id 32382 --accept-terms-of-use --jwt-secret jwt.hex --suggested-fee-recipient 0x123463a4B065722E99115D6c222f267d9cABb524 --minimum-peers-per-subnet 0 --enable-debug-rpc-endpoints --execution-endpoint gethdata/geth.ipc
```

### validator

```shell
./validator --datadir validatordata --accept-terms-of-use --interop-num-validators 64 --chain-config-file config.yml
```