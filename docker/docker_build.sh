docker build -t uwgac/genesis:2.24.0 -f genesis.dfile .
docker build --no-cache -t uwgac/genesis-workflow:3.0.0 -f genesis-workflow.dfile .
