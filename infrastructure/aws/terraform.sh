#!/bin/bash

set -e -o xtrace

export AWS_PROFILE=${1}
shift

terraform init -reconfigure -backend-config=variables/terraform.tfvars
terraform ${@} -var-file=variables/environment.tfvars
