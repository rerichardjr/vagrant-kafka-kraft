#!/bin/bash

set -euxo pipefail

source "$(dirname "$0")/lib.sh"

BASE_URL="https://downloads.apache.org/kafka/${KAFKA_VERSION}"
KAFKA_INSTALLER="kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
CHECKSUM_ALGO=sha512
KAFKA_CHECKSUM="${KAFKA_INSTALLER}.${CHECKSUM_ALGO}"
SHARED_FOLDER="/vagrant"
STAGE_FOLDER="${SHARED_FOLDER}/stage"
SERVER_PROPERTIES="${INSTALL_FOLDER}/config/kraft/server.properties"


installKafka() {
  sudo mkdir ${INSTALL_FOLDER} ${LOG_FOLDER}
  sudo chown ${RUN_AS_USER}:${RUN_AS_USER} ${INSTALL_FOLDER} ${LOG_FOLDER}
  sudo -u ${RUN_AS_USER} tar xzf "${STAGE_FOLDER}/${KAFKA_INSTALLER}" -C ${INSTALL_FOLDER} --strip 1
}

createKafkaServerProperties() {
  local quorum_voters

  quorum_voters=$(printf "%s," $(seq 1 "$NODE_COUNT" | xargs -I{} echo "{}@${HOSTNAME}{}.${DOMAIN}:9093"))
  quorum_voters=${quorum_voters%,}  # remove trailing comma

  sudo -u ${RUN_AS_USER} mv $SERVER_PROPERTIES $SERVER_PROPERTIES.orig

  if [ ! -f $SERVER_PROPERTIES ]; then
    sudo -u ${RUN_AS_USER} cat > $SERVER_PROPERTIES <<EOF
process.roles=broker,controller
node.id=${NODE_ID}
controller.quorum.voters=${quorum_voters}
listeners=PLAINTEXT://${HOSTNAME}${NODE_ID}.${DOMAIN}:9092,CONTROLLER://${HOSTNAME}${NODE_ID}.${DOMAIN}:9093
inter.broker.listener.name=PLAINTEXT
advertised.listeners=PLAINTEXT://${HOSTNAME}${NODE_ID}.${DOMAIN}:9092
controller.listener.names=CONTROLLER
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL
log.dirs=${LOG_FOLDER}/kraft-combined-logs
num.partitions=${NODE_COUNT}
auto.create.topics.enable=false
EOF
fi
}

generateClusterID() {
  local id_file="${SHARED_FOLDER}/files/cluster_id.txt"
  local cluster_id

  if [ "$NODE_ID" -eq 1 ]; then
    # if first node, create cluster id and save id so other vms can access
    sudo -u ${RUN_AS_USER} ${INSTALL_FOLDER}/bin/kafka-storage.sh random-uuid > $id_file 
  fi

  cluster_id=$(cat $id_file)
  sudo -u ${RUN_AS_USER} ${INSTALL_FOLDER}/bin/kafka-storage.sh format -t $cluster_id -c ${SERVER_PROPERTIES}
}

createKafkaService() {
  local kafka_service="/etc/systemd/system/kafka.service"

  if [ ! -f $kafka_service ]; then
    cat > $kafka_service <<EOF
[Unit]
Description=Kafka Service
Requires=network.target
After=network.target
StartLimitIntervalSec=300
StartLimitBurst=25

[Service]
Type=simple
User=${RUN_AS_USER}
ExecStart=${INSTALL_FOLDER}/bin/kafka-server-start.sh ${INSTALL_FOLDER}/config/kraft/server.properties
ExecStop=${INSTALL_FOLDER}/bin/kafka-server-stop.sh
StandardOutput=append:${LOG_FOLDER}/kafka.log
StandardError=append:${LOG_FOLDER}/kafka.err
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
fi
}

createServiceAccount ${RUN_AS_USER} ${RUN_AS_USER}
installCorretto
downloadFile ${BASE_URL} ${KAFKA_INSTALLER} ${STAGE_FOLDER}
downloadFile ${BASE_URL} ${KAFKA_CHECKSUM} ${STAGE_FOLDER}
gpgVerify ${STAGE_FOLDER} ${KAFKA_INSTALLER} ${KAFKA_CHECKSUM} ${CHECKSUM_ALGO}
installKafka
createKafkaServerProperties
generateClusterID
createKafkaService
startService kafka
updateProfilePath "${INSTALL_FOLDER}/bin" "kafka-bin-path.sh"
