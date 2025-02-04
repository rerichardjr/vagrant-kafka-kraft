# Kafka Cluster with KRaft Mode - Vagrant Setup

This repository contains a **Vagrantfile** designed to provision a Kafka cluster running in **KRaft (Kafka Raft) mode**, eliminating the need for ZooKeeper. The setup leverages Vagrant and VirtualBox to create a consistent, reproducible environment for development, testing, or learning purposes.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation Guide](#installation-guide)
  - [Installing VirtualBox](#installing-virtualbox)
  - [Installing Vagrant](#installing-vagrant)
- [Configuration](#configuration)
- [Usage](#usage)
- [Folder Structure](#folder-structure)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features
- Automated deployment of a Kafka cluster using Vagrant and VirtualBox.
- **KRaft Mode:** Kafka operates natively without ZooKeeper, simplifying cluster management.  
- **Multi-Node Cluster:** Provisions multiple Kafka broker nodes to simulate a real cluster environment.  
- Configurable settings via `settings.yaml`.
- Custom bash scripts for further node configuration, located in the `scripts` folder.

## Prerequisites
Ensure you have the following installed:
- VirtualBox
- Vagrant
- Git

## Installation Guide

### Installing VirtualBox

#### **Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y virtualbox
```

#### **Fedora/RHEL:**
```bash
sudo dnf install -y @virtualization
sudo systemctl start vboxdrv
sudo systemctl enable vboxdrv
```

#### **macOS (with Homebrew):**
```bash
brew install --cask virtualbox
```

#### **Windows:**
1. Download the installer from [VirtualBox Downloads](https://www.virtualbox.org/wiki/Downloads).
2. Run the installer and follow the on-screen instructions.

### Installing Vagrant

#### **Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y vagrant
```

#### **Fedora/RHEL:**
```bash
sudo dnf install -y vagrant
```

#### **macOS (with Homebrew):**
```bash
brew install --cask vagrant
```

#### **Windows:**
1. Download the installer from [Vagrant Downloads](https://www.vagrantup.com/downloads).
2. Run the installer and follow the on-screen instructions.

## Configuration
All configuration options are managed through the `settings.yaml` file.

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
4. To SSH into a VM:
   ```bash
   vagrant ssh <vm_name>
   ```
5. To halt the cluster:
   ```bash
   vagrant halt
   ```
6. To destroy the cluster:
   ```bash
   vagrant destroy -f
   ```

## Folder Structure
```
.
├── Vagrantfile
├── settings.yaml
├── scripts/
│   └── kafka-kraft.sh
└── README.md
```

## Troubleshooting
- **VM Startup Issues:**
  - Ensure virtualization is enabled in BIOS/UEFI.
  - Verify VirtualBox and Vagrant versions are compatible.

- **Add-on Installation Fails:**
  - Review logs inside the VM (`/var/log` or specified log files).
  - Ensure internet connectivity inside the VM.

## License
This project is licensed under the [MIT License](LICENSE).

