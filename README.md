# MDBconductor-deploy

Deploy MDBconductor on AWS using Terraform and Ansible.

## Terraform configuration


To start the virtual machines, cd into `terra`.

1. If this is the first time, run `terraform init`.

2. Copy `terraform.tfvars.example` to `terraform.tfvars` and edit the file to
   reflect your experiment, for example the EC2 region to deploy to and the ssh
   key to use.

3. Run `terraform apply`, inspect the output and type 'yes' if ok.

The Terraform configuration adds tags 'clustername' and 'cluster_groups' to the
virtual machines. The conductor gets `clustergroups=['conductor']` and the
minions get `cluster_groups=['minions']`. The Ansible configuration below uses
these tags to put them in the right group.

### Directory layout

```plain
terra/                            # Terraform config
  general.tf
  variables.tf                    # variable definitions
  terraform.tfvars.example        # example of how to set the variables
  machines.tf                     # aws_instance resources
  network.tf                      # security group definitions
  roles.tf                        # allow conductor to start/stop the minions
  Makefile                        # convenience to extract ssh-config from Terraform state
```

## Ansible playbook for MDBconductor

When Terraform has completed we use Ansible to further set up the machines. The
configuration as given here provides two environments, a staging and a
production environment. Unfortunately this separation is not yet reflected in
the Terraform setup described above.

Before running Ansible, take a look at the settings in `inventories/common.yml`
and `inventories/{staging,production}/settings.yml`. Then run `ansible-playbook
-i inventories/staging site.yml` to set up the test environment.

### Directory Layout

The top level directory contain the following files and directories:

```plain
inventories/
  common.yml                 # common Ansible settings such as MDB_VERSION
  parse-terraform-state.py   # script to import Terraform resources into Ansible
  production/
      common.yml             # symlink to ../common.yml
      from-terraform.sh      # dynamic inventory invoking ../parse-terraform-state.py
      settings.yml           # environment-specific settings such as TPCH_SCALE_FACTOR
  staging/
      from-terraform.sh      # (as above)
      settings.yml
      common.yml
roles/
  common/
    tasks/
      main.yml               # common tasks on all machines, e.g. install MonetDB and TPC-H scripts
    templates/
      etc_hosts.in           # used for the instances to find each other
  monetdb/
    handlers/
      main.yml               # handles what we want to do with MonetDB, e.g., (re)start `monetdbd`
    tasks/
      main.yml               # install MonetDB and set up some basic environment stuff for it
    templates/
      monetdb.list.in        # template for MonetDB Apt sources list (see ../tasks/main.yml)
  tpch/
    defaults/
      main.yml               # set up some default values
    tasks/
      main.yml               # prepare a TPC-H database of TPCH_SCALE_FACTOR
    templates/
      tpch.service.in        # start a TPC-H systemd service (i.e. mserver5) to serve the TPC-H database
site.yml                     # the master playbook
conductor.yml                # playbook for the conductor
```
