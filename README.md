# Kafka Cluster with KRaft Mode — Vagrant Setup

This repository provisions a multi-node Kafka cluster running in **KRaft (Kafka Raft) mode**, using **Vagrant** and **VirtualBox**. It's ideal for development, testing, and learning environments that require a reproducible Kafka setup without ZooKeeper.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Usage](#usage)
- [Validation](#validation)
- [Cleanup](#cleanup)
- [License](#license)

---

## Features

- Automated provisioning of a Kafka cluster using Vagrant and VirtualBox  
- **KRaft Mode**: Kafka runs natively without ZooKeeper  
- **Multi-node cluster**: Simulates a real-world broker environment  
- Configurable via `settings.yaml`  
- Custom Bash scripts for node setup in the `scripts/` directory  

---

## Prerequisites

Ensure the following tools are installed on your host machine:

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- [Git](https://git-scm.com/)

---

## Configuration

All cluster settings are defined in `settings.yaml`. You can adjust:

- Number of nodes  
- Kafka version  
- Network settings  
- Resource allocations  

---

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/rerichardjr/vagrant-kafka-kraft.git
   cd vagrant-kafka-kraft
   ```

2. Modify `settings.yaml` as needed.

3. Start the cluster:
   ```bash
   vagrant up
   ```

---

## Validation

### 1. SSH into a node:
```bash
vagrant ssh node1
```

### 2. Verify broker connectivity:
```bash
kafka-broker-api-versions.sh --bootstrap-server node1.test.local:9092
```

Sample output:
```
node3.test.local:9092 (id: 3 rack: null) -> (
  Produce(0): 0 to 11 [usable: 11],
  Fetch(1): 0 to 17 [usable: 17],
  ...
)
```

### 3. Create a topic:
```bash
kafka-topics.sh --bootstrap-server node1.test.local:9092 \
  --create --topic my-topic \
  --partitions 3 --replication-factor 3
```

Output:
```
Created topic my-topic.
```

### 4. Describe the topic:
```bash
kafka-topics.sh --bootstrap-server node1.test.local:9092 \
  --describe --topic my-topic
```

Sample output:
```
Topic: my-topic  PartitionCount: 3  ReplicationFactor: 3
Partition: 0  Leader: 2  Replicas: 2,3,1  Isr: 2,3,1
Partition: 1  Leader: 3  Replicas: 3,1,2  Isr: 3,1,2
Partition: 2  Leader: 1  Replicas: 1,2,3  Isr: 1,2,3
```

---

## Cleanup

To destroy the cluster and remove all VMs:
```bash
vagrant destroy -f
```

---

## License

This project is licensed under the [MIT License](LICENSE).

---

