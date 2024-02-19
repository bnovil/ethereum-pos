
ACCOUNT_ADDR = 400ab0adb4fa0ae7e7486ef76be44e9d64fbfab4


build_prysm:
	git clone https://github.com/prysmaticlabs/prysm
	cd prysm; \
	go build -o=../cmd/beacon-chain ./cmd/beacon-chain; \
	go build -o=../cmd/validator ./cmd/validator; \
	go build -o=../cmd/prysmctl ./cmd/prysmctl

build_geth:
	git clone https://github.com/ethereum/go-ethereum
	cd go-ethereum; \
	make geth; \
	cp ./build/bin/geth ../cmd/geth


import_account:
	./cmd/geth --datadir=data/gethdata account import config/account_secret.txt


clear_data:
	rm -r data/gethdata/geth
	rm -r data/beacondata
	rm -r data/validatordata


init_genesis:
	./cmd/geth --datadir=data/gethdata init config/genesis.json


run_geth:
	./cmd/geth --http --http.api eth,net,web3 --ws --ws.api eth,net,web3 --authrpc.jwtsecret config/jwt.hex --datadir data/gethdata --nodiscover --syncmode full --allow-insecure-unlock --unlock $(ACCOUNT_ADDR) --vmodule 'rpc=5'


regenerate_genesis_ssz:
	./cmd/prysmctl testnet generate-genesis --fork capella --num-validators 64 --genesis-time-delay 600 --chain-config-file config/config.yml --geth-genesis-json-in config/genesis.json  --geth-genesis-json-out config/genesis.json --output-ssz config/genesis.ssz


run_beacon_chain:
	./cmd/beacon-chain --datadir=data/beacondata --min-sync-peers=0 --genesis-state=config/genesis.ssz --bootstrap-node= --interop-eth1data-votes --chain-config-file=config/config.yml --contract-deployment-block=0 --chain-id=32382 --rpc-host=0.0.0.0 --grpc-gateway-host=0.0.0.0 --execution-endpoint=http://localhost:8551 --accept-terms-of-use --jwt-secret=config/jwt.hex --suggested-fee-recipient=$(ACCOUNT_ADDR)  --minimum-peers-per-subnet=0 --enable-debug-rpc-endpoints --force-clear-db


run_validator:
	./cmd/validator --beacon-rpc-provider=localhost:4000 --datadir=data/validatordata --accept-terms-of-use --interop-num-validators=64 --interop-start-index=0 --chain-config-file=config/config.yml --force-clear-db