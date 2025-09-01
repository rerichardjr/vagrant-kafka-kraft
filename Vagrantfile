require 'yaml'
require 'json'
settings = YAML.load_file "settings.yaml"

HOSTNAME = settings["host"]["hostname"]
COUNT = settings["host"]["count"]
NETWORK = settings["ip"]["network"]
IP_START = settings["ip"]["start"]
DOMAIN = settings["ip"]["domain"]
SCALA_VERSION = settings["software"]["scala"]
KAFKA_VERSION = settings["software"]["kafka"]
BRIDGE = settings["bridge"]
SUPPORT_USER = settings["support_user"]
FOLDERS = %w[stage files keys]

# ─── Banner ──────────────────────────────────────────────────────
load 'banner.rb'

# ─── Build hostname-to-IP map ─────────────────────────────────────
hostname_ip_map = (1..COUNT).map do |i|
  ["#{HOSTNAME}#{i}", "#{NETWORK}.#{IP_START + i - 1}"]
end.to_h

map_json = hostname_ip_map.to_json

# ─── Ensure required folders exist ────────────────────────────────
FOLDERS.each do |folder|
  unless Dir.exist?(folder)
    puts "\e[32mCreating #{folder} folder...\e[0m"
    Dir.mkdir(folder)
  end
end

# ─── Vagrant configuration ───────────────────────────────────────
Vagrant.configure("2") do |config|
  config.vm.box = settings["software"]["box"]
  config.vm.box_check_update = true

  config.vm.provision "file", source: "scripts/lib.sh", destination: "/tmp/lib.sh"
  
  config.vm.provision "shell",
    name: "Support user creation",
    env: {
      "SUPPORT_USER" => SUPPORT_USER,
    },
    path: "scripts/common.sh"

    config.vm.provision "shell",
    name: "Networking configuration",
    env: {
      "IP" => IP_START,
      "NETWORK" => NETWORK,
      "DOMAIN" => DOMAIN,
      "HOSTNAME_IP_MAP" => map_json,
      "HOSTNAME" => HOSTNAME,
    },
    path: "scripts/networking.sh"

  # Node definitions
  hostname_ip_map.each_with_index do |(node_name, node_ip), idx|
    config.vm.define node_name do |host|
      host.vm.hostname = node_name
      host.vm.network :public_network, ip: node_ip, bridge: BRIDGE

      host.vm.provider "virtualbox" do |vb|
        vb.cpus   = settings["host"]["cpu"]
        vb.memory = settings["host"]["memory"]
      end

      host.vm.provision "shell",
        name: "Configure Kafka nodes",
        env: {
          "SCALA_VERSION"  => SCALA_VERSION,
          "KAFKA_VERSION"  => KAFKA_VERSION,
          "HOSTNAME"       => HOSTNAME,
          "NODE_ID"        => (idx + 1).to_s,
          "NODE_COUNT"     => COUNT,
          "NETWORK"        => NETWORK,
          "IP"             => IP_START + idx,
          "DOMAIN"         => DOMAIN,
          "RUN_AS_USER"    => settings["configs"]["run_as_user"],
          "INSTALL_FOLDER" => settings["configs"]["install_folder"],
          "LOG_FOLDER"     => settings["configs"]["log_folder"]
        },
        path: "scripts/kafka-kraft.sh"
    end
  end
end
