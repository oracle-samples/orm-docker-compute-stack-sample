#!/bin/bash
#
## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl
#
# cloud-init script for Docker compute instance
#
# Description: Run by cloud-init at instance provisioning.
#   - install Docker / docker-compose

PGM=$(basename $0)

DOCKER_COMPOSE_REPO="https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-Linux-x86_64"

#######################################
# Print header
# Globals:
#   PGM
#######################################
echo_header() {
  echo "+++ $PGM: $@"
}

#######################################
# Format & mount block volume
#######################################
mount_volume() {

	echo_header "Mount block volume"

	# Make a directory for block volume
	sudo mkdir ${mount_dir}

	# Format disk
	yes | sudo mkfs.ext4 /dev/sdb

	# Mount volume
	sudo mount /dev/sdb ${mount_dir}
}

#######################################
# Install docker
# Globals:
#   DOCKER_REPO, USER, YUM_OPTS
#######################################
install_docker() {
	echo_header "Install Docker"

    # Setup yum
	sudo yum install -y yum-utils device-mapper-persistent-data lvm2

	echo_header "Install docker repo"
	# Install docker repo
	sudo yum-config-manager --add-repo ${docker_repo_url}

	echo_header "Install docker-ce"
	# Install docker
	sudo yum install -y docker-ce

	echo_header "Add User to docker group"
	# Add User to docker group
	usermod -a -G docker ${username}

}

#######################################
# Install docker compose
# Globals:
#   DOCKER_REPO, USER, YUM_OPTS
#######################################
install_docker_compose() {
	echo_header "Install Docker Compose"
	
	# By default, the latest version of Docker Compose is not available in the 
	# Oracle Linux default repository, so you will need to download it from the Git Hub repository.
	sudo curl -SL $DOCKER_COMPOSE_REPO -o /usr/local/bin/docker-compose
	
	# Set executable permission on the Docker Compose binary
	sudo chmod +x /usr/local/bin/docker-compose

	# Create symbolic link
	sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

#######################################
# Update Docker location
# Globals:
#   DOCKER_DIR
#######################################
update_docker_location() {
	echo_header "Update Docker location"
	
	# Create new folder for Docker data root
	sudo mkdir -p ${mount_dir}/docker/data

	# Create Docker config folder if not exists
	sudo mkdir -p /etc/docker
		
	# Create Docker daemon.json file and change Docker root folder
	cat <<EOF > /etc/docker/daemon.json
{"data-root" : "${mount_dir}/docker/data"}
EOF
	
	# Restart docker
	#systemctl start docker
}
	
#######################################
# Check Docker info
#######################################
start_docker() {
	echo_header "Start Docker"

	# Enable and start Docker
	sudo systemctl enable docker
	sudo systemctl start docker
	
	#docker info
}


#######################################
# Setup docker compose YAML file
# When you create a script from this script, the bash variables are escaped differently.
# Use backslash double dollar sign to escape terraform interpolation.
# See https://faun.pub/terraform-ec2-userdata-and-variables-a25b3859118a
#######################################
setup_docker_compose_yaml() {
	echo_header "Setup docker compose YAML configuration"

	# Change to mount folder
	cd ${mount_dir}
	
	# Create docker compose YAML configuration file
	cat <<EOF > docker-compose.yaml
version: '3.7'
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "6831:6831/udp"
      - "${trace_server_port}:${trace_server_port}"
    networks:
      - jaeger-example
  hotrod:
    image: jaegertracing/example-hotrod:latest
    ports: 
      - "${web_server_port}:${web_server_port}"
    command: ["all"]
    environment:
      - JAEGER_AGENT_HOST=jaeger
      - JAEGER_AGENT_PORT=6831
    networks:
      - jaeger-example
    depends_on:
      - jaeger

networks:
  jaeger-example:
EOF

}


#######################################
# Main
#######################################
main() {

	cp /etc/motd /etc/motd.bkp
	cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)
 
EOF

	mount_volume
	install_docker	
	install_docker_compose
	update_docker_location
	start_docker
	setup_docker_compose_yaml
}

main "$@"