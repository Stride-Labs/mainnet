strided tx slashing unjail --from val1 --keyring-backend test --chain-id=STRIDE 

strided tx staking redelegate stridevaloper1eqahrt8nu2xx394puzppuy49csmu268847cckf stridevaloper1zfrw4r3lnlvw5v3m5fgckayvqlhx5l308gn03z  1000000000000ustrd --from val2 --keyring-backend test --chain-id STRIDE --gas 300000 

strided tx staking redelegate stridevaloper1e3ueja9qgqdeuj3r9mahc69g2ll0eafrv4wdv7 stridevaloper1gt70ctd7fg428p4rlsxe2ez4sg59yan8s8yp3a 1000000000000ustrd --from val1 --keyring-backend test --chain-id STRIDE --gas 300000 



strided tx staking redelegate stridevaloper1ad22g9hscw35v7tq3d28c3kek79knn0mn8qjjv stridevaloper1eqahrt8nu2xx394puzppuy49csmu268847cckf 1000000000000ustrd --from val3 --keyring-backend test --chain-id STRIDE --gas 300000 

gaiad tx staking redelegate cosmosvaloper1lxr8hwj336jqexjwsahrne00w0hwnk5t2wsamu cosmosvaloper1lc6klxh9c3lk7q3t3s3anf0tqfucgtqcxdlmrt 50000000000000uatom --from gval1 --keyring-backend test --chain-id GAIA --gas 300000 -y