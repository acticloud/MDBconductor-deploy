#!/bin/sh

HERE="$(dirname "$0")"
exec "$HERE/../parse-terraform-state.py" "$HERE/../../terra/terraform.tfstate"
