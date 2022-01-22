#!/bin/bash

set -e -o xtrace

export AWS_PROFILE=${1}
shift

terraform import -var-file=variables/environment.tfvars ${@}
