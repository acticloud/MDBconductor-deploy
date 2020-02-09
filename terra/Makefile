default: ssh-config

refresh:	_refresh_ ssh-config

_refresh_:
	terraform refresh

# This commmand generates the following SSH config output:
## Host HOSTNAME
##    Hostname IP
##    User ubuntu
##    IdentityFile ~/.ssh/joeri-aws.pem
ssh-config: terraform.tfstate Makefile
	>$@.tmp <$< jq -r '.resources[] | select(.provider == "provider.aws" and .type == "aws_instance") | .instances[] | select((.attributes.public_ip | length) > 0) | .attributes | "Host \(.tags.Name)\n    Hostname \(.public_ip)\n    User ubuntu\n\n"'
	diff -c $@ $@.tmp || mv $@.tmp $@
