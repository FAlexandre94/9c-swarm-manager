#!/bin/bash

# set -x

# source ./scripts/log.sh
# source ./scripts/lib.sh
# checkARGs
# checkVERSION
# checkParams

# Variables
composeFile='docker-compose.swarm.yml'

# Generate docker-compose-override.yml
function buildComposeFile() {
    log debug "  --building $composeFile"

    cat <<EOF >$composeFile
version: "2.4"

services:
EOF
    
    for ((i=1; i<=$MINERS; i++)); do
        argName="NAME_MINER_${i}"
        CONTAINERNAME=(${!argName})
        PEERPORT=$((PEER_PORT++))
        GRAPHQLPORT=$((GRAPHQL_PORT++))
        
        log trace "    --[$composeFile] TEST: $NAME_MINER_1"
        log trace "    --[$composeFile] LOADING: $argName"
        log trace "    --[$composeFile] CONTAINER_NAME: $CONTAINERNAME"
        log trace "    --[$composeFile] PEER_PORT: $PEERPORT"
        log trace "    --[$composeFile] GRAPHQL_PORT: $GRAPHQLPORT"

        cat <<EOF >>$composeFile
  $CONTAINERNAME:
    image: $DOCKER_IMAGE
    container_name: $CONTAINERNAME
    mem_limit: $RAM_LIMIT
    mem_reservation: $RAM_RESERVE
    ports:
      - "$PEERPORT:31234"
      - "$GRAPHQLPORT:23061"
    volumes:
      - /var/run/docker.sock:/var/run/docker-host.sock
      - $CONTAINERNAME:/app/data
      - $CONTAINERNAME:/app/planetarium/keystore
      - $CONTAINERNAME:/secret
    healthcheck:
      test: ["CMD", "./scripts/healthcheck.sh", "--check-ping"]
      interval: 1m30s
      timeout: 30s
      retries: 3
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        "max-size": "40m"
        "max-file": "1"
    command: ['-V=$APV',
      '-G=https://9c-test.s3.ap-northeast-2.amazonaws.com/genesis-block-9c-main',
      '-D=5000000',
      '--store-type=monorocksdb',
      '--store-path=/app/data',
      '--peer=027bd36895d68681290e570692ad3736750ceaab37be402442ffb203967f98f7b6,9c-main-seed-1.planetarium.dev,31234',
      '--peer=02f164e3139e53eef2c17e52d99d343b8cbdb09eeed88af46c352b1c8be6329d71,9c-main-seed-2.planetarium.dev,31234',
      '--peer=0247e289aa332260b99dfd50e578f779df9e6702d67e50848bb68f3e0737d9b9a5,9c-main-seed-3.planetarium.dev,31234',
      '--trusted-app-protocol-version-signer=03eeedcd574708681afb3f02fb2aef7c643583089267d17af35e978ecaf2a1184e',
      '--workers=500',
      '--confirmations=2',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us2.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us3.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us4.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us5.planetarium.dev:3478',
      '--graphql-server',
      '--graphql-port=23061',
      '--graphql-secret-token-path=/secret/token',
      "--miner-private-key=$PRIVATE_KEY"]
EOF
    done

    cat <<EOF >>$composeFile
volumes:
EOF

    for ((i=1; i<=$MINERS; i++)); do
        argName="NAME_MINER_${i}"
        CONTAINERNAME="${!argName}"

        cat <<EOF >>$composeFile
  $CONTAINERNAME:
EOF
    done

    if [ -f "$composeFile" ]; then
        log debug "  --created $composeFile file"
    else
        log error "[buildComposeFile] File not created"
    fi
}

###############################
# TODO_MODIFY: Add function to test recreate only if different
function dockerCompose() {
    log info "> Generating $composeFile..."
    
    if [ -f "$composeFile" ]; then
      log debug "  --found existing file"
      rm -f $composeFile
      log debug "  --cleaned existing file"
      buildComposeFile
    else
      log debug "  --file not found"
      buildComposeFile
    fi
    echo
}
###############################