# MDBconductor-deploy

Deploy MDBconductor on AWS using Terraform and Ansible.

## Terraform configuration


To start the virtual machines, cd into `terra`.

1. If this is the first time, run `terraform init`.

2. Copy `terraform.tfvars.example` to `terraform.tfvars` and edit the file to
   reflect your experiment, for example the EC2 region to deploy to and the ssh
   key to use.

3. Run `terraform apply`, inspect the output and type 'yes' if ok.

The terraform configuration adds tags 'clustername' and 'cluster_groups' to the
virtual machines. The conductor gets `clustergroups=['conductor']` and the
minions get `cluster_groups=['minions']`. The Ansible configuration below uses
these tags to put them in the right group.

### Directory layout

```plain
terra/                              # Terraform config
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
-i inventories/staging` to set up the test environment.

### Directory Layout

The top level directory contain the following files and directories:

```plain
inventories/
    common.yml                      # common Ansible settings such as MDB_VERSION
    parse-terraform-state.py        # script to import Terraform resources into Ansible
    production/
        common.yml                  # symlink to ../common.yml
        from-terraform.sh           # dynamic inventory invoking ../parse-terraform-state.py
        settings.yml                # environment-specific settings such as TPCH_SCALE_FACTOR
    staging/
        from-terraform.sh           # (as above)
        settings.yml
        common.yml

templates
    monetdb.list.in                 # template for Apt sources list of MonetDB Ubuntu package
    etc_hosts.in                    # template for /etc/hosts on the EC2 hosts
site.yml                            # the master playbook
conductor.yml                       # playbook for the conductor
minions.yml                         # playbook for the minions
```
