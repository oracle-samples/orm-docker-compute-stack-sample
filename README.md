# ORM Docker Compute Stack

Oracle Cloud Infrastructure [Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) stack configuration for Docker and Docker Compose setup. The objective is to install Docker and Docker Compose on an OCI Compute with attached Block Volume. Since standard OCI compute has less memory for Docker to run, we will be creating a block volume and attaching it to the OCI compute and then installing Docker on the blockvolume

## Resource Manager

Resource Manager is an Oracle Cloud Infrastructure service that allows you to automate the process of provisioning your Oracle Cloud Infrastructure resources. Using [Terraform](https://www.terraform.io/), Resource Manager helps you install, configure, and manage resources through the "infrastructure-as-code" model.

A Terraform configuration codifies your infrastructure in declarative configuration files. Resource Manager allows you to share and manage infrastructure configurations and state files across multiple teams and platforms. This infrastructure management can't be done with local Terraform installations and Oracle Terraform modules alone


## Getting Started

When you [sign up](https://www.oracle.com/cloud/free/) for an Oracle Cloud Infrastructure account, you’re assigned a secure and isolated partition within the cloud infrastructure called a *tenancy*. The tenancy is a logical concept and you can think of it as a root container where you create, organize, and administer your cloud resources. 

The second logical concept used for organizing and controlling access to cloud resources is compartments. A *compartment* is a collection of related cloud resources.Every time you create a cloud resource, you must specify the compartment that you want the resource to belong to.

Ensure you have access to a compartment in your tenancy as well as [Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm).

### Create Stack

Follow the instructions to [create a stack from a zip file](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm)

#### Console Instructions

1. Open the navigation menu and click Developer Services. Under Resource Manager, click Stacks.
2. Choose a compartment that you have permission to work in.
3. Click Create stack.
4. In the Create stack page, under Choose the origin of the Terraform configuration, select My configuration.
5. Under Stack configuration, select .Zip file.
6. Drag and drop a .zip file onto the dialog's control or click Browse and navigate to the location of the .zip file you want. The dialog box is populated with information contained in the Terraform configuration.
7. Fill in the remaining fields.
8. Review and click Create to create your stack.

#### CLI Instructions

Use the ```oci resource-manager stack create``` [command](https://docs.oracle.com/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/resource-manager/stack/create.html) and required parameters to create a stack from a local zip file.

Example request:

```
oci resource-manager stack create --compartment-id ${compartment.ocid} --config-source ${zipfile} --variables file://variables.json --display-name "Docker Compute Stack" --description "Example Docker Compute stack" --working-directory ""
```

Note, the ```variables``` parameter allows you to pass through Terraform variables associated with this resource. Example: {"vcn_cidr_block": "10.0.0.0/16"} This is a complex type whose value must be valid JSON. The value can be provided as a string on the command line or passed in as a file using the file://path/to/file syntax.

### Apply Stack

When you run an apply job for a stack, Terraform provisions the resources and executes the actions defined in your Terraform configuration, applying the execution plan to the associated stack to create your Oracle Cloud Infrastructure resources. We recommend running a plan job (generating an execution plan) before running an apply job.

#### Console Instructions

1. Open the navigation menu and click Developer Services. Under Resource Manager, click Stacks.
2. Choose a compartment that you have permission to work in.
3. Click the name of the stack that you want. The Stack details page opens.
4. Click Apply. 

#### CLI Instructions

Use the ```oci resource-manager job create-apply-job``` [command](https://docs.oracle.com/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/resource-manager/job/create-apply-job.html) and required parameters to run an apply job.

Example request using automatically approve option:

```
oci resource-manager job create-apply-job --execution-plan-strategy AUTO_APPROVED  --stack-id ${stack.ocid}
```

### Starting Container

The compute instance which the stack will create contains a [cloud-init](https://cloudinit.readthedocs.io/en/latest/) script. Cloud-init is the industry standard multi-distribution method for cross-platform cloud instance initialisation and provides the necessary glue between launching a cloud instance and connecting to it so that it works as expected.

The cloud-init script will attach the file system found on the block volume device at the location specified by the ```mount_dir``` variable. To start Docker Compose in your instance you will need to SSH into the instance, change directories to the specified ```mount_dir```, upload a Docker Compose YAML file, and call the Docker command ```docker-compose up``` to start and run the specified application.


## Resources

The following resources are created in the specified compartment.

### Network

Network resources include a Virtual Cloud Network (VCN), public and private subnets, and the corresponding route table, internet gateway and security list. Security list ingress rules allow traffic on port 22 for SSH access to the compute instance and traffic for the web server (defaults to 8080) and [Jaeger](https://www.jaegertracing.io/) (defaults to 16686).
 
| Name | Type | Description |
| ----------- | ----------- | ----------- |
| vcn-oci-server | [oci_core_vcn](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn) | Virtual Cloud Network (VCN) in specified compartment. See [VCNs and Subnets](https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingVCNs.htm) |
| public-subnet-vcn-oci-server | [oci_core_subnet](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | Public subnet resource in the specified VCN |
| private-subnet-vcn-oci-server | [oci_core_subnet](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | Private subnet resource in the specified VCN |
| ig-vcn-oci-server | [oci_core_internet_gateway](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway) | Internet gateway resource in the specified VCN |
| routetable-vcn-oci-server | [oci_core_route_table](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | Route table resource in the specified VCN |
| seclist-vcn-oci-server | [oci_core_security_list](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | Security list resource in the specified VCN see [Security Lists](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/securitylists.htm) |


## Compute

Compute resources include the compute instance and a block volume, which is where Docker and Docker Compose will be installed.

| Name | Type | Description |
| ----------- | ----------- | ----------- |
| block-volume-oci-server | [oci_core_volume](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume) | Block volume resource in the specified compartment. |
| oci-server | [oci_core_instance](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance) | Compute instance resource in the specified compartment. |
| block-volume-attachment-oci-server | [oci_core_volume_attachment](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_attachment) | Attaches the specified storage volume to the specified instance. |


## Variables

There are a number of variables that are employed by the stack.

| Name | Description | Default Value |
| ----------- | ----------- | ----------- |
| *tenancy_ocid* | Tenancy OCID | Automatically populated by OCI. See [Terraform Configurations for Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm) |
| *region* | Region name | Automatically populated by OCI. See [Terraform Configurations for Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm) |
| *compartment_ocid* | Compartment OCID | Automatically populated by OCI. See [Terraform Configurations for Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm) |
| *ssh_public_key* | SSH public Key used to login to compute instance |  |
| *compute_display_name* | Compute display name | oci-server-01 |
| *vcn_cidr_block* | Virtual cloud network CIDR block | 10.0.0.0/16 |
| *vcn_public_subnet_cidr_block* | Public subnet CIDR block | 10.0.0.0/24 |
| *vcn_private_subnet_cidr_block* | Private subnet CIDR block | 10.0.1.0/24 |
| *ad* | Availability domain to deploy resources |  |
| *image_operating_system* | Compute image operating system | Oracle Linux |
| *instance_shape* | Compute image shape | VM.Standard.E2.1.Micro |
| *mount_dir* | Block volume mount directory | /scratch |
| *volume_size_in_gbs* | Block volume size (GB) | 50 |
| *docker_compose_version* | Docker Compose version | 3.3 |
| *web_server_port* | Web server port | 8080 |
| *trace_server_port* | [Jaeger](https://www.jaegertracing.io/) service port | 16686 |


## Cloud-Init Script

The cloud-init script will take the following actions. You can see [cloud-init output logs](https://cloudinit.readthedocs.io/en/20.1/topics/logging.html) at `var/log/cloud-init-output.log`.
Check progress in Linux 7.9 using ```sudo grep cloud-init /var/log/messages```

- **Mount block volume**

Format and mount block volume at the location specified by ```mount_dir```.

- **Install Docker**

Add Docker respository and install Docker [yum](https://yum.oracle.com/getting-started.html) server.  Add User to docker group.

- **Install Docker Compose**

Download and install Docker Compose version specified by ```docker_compose_version```.

- **Update Docker Location**

Update Docker *data-root* location to ```mount_dir``` in order to ensure enough disk space for Docker containers.

- **Start Docker**

Enable and start Docker.


- **Setup Docker Compose Configuration**

Setup Docker Compose YAML configuration at the location specified by the ```mount_dir`` stack variable.

The configuration contents are:

```
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

```

## Contributing

This project welcomes contributions from the community. Before submitting a pull request, please [review our contribution guide](./CONTRIBUTING.md)

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security vulnerability disclosure process

## License
Copyright (c) 2024, Oracle and/or its affiliates.
Released under the Universal Permissive License v1.0 as shown at <https://oss.oracle.com/licenses/upl/>.

## Distribution
 
Developers choosing to distribute a binary implementation of this project are responsible for obtaining and providing all required licenses and copyright notices for the third-party code used in order to ensure compliance with their respective open source licenses.