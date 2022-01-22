#!/bin/bash

set -e -o xtrace

export AWS_PROFILE=${1}
shift

terraform state ${@}
