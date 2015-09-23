#!/bin/bash
set -x
export AGAVE_JOB_ID="test123345"
export AGAVE_JOB_NAME="testuser-runner"
export AGAVE_JOB_CALLBACK_FAILURE=""
export unpackInputs=1
export appBundle="testdata.tgz"
export dockerImage="agaveapi/scipy-matplot-2.7"
export dockerFile=''
export command="python"
export commandArgs="main.py"

# This is a generic wrapper script for running docker containers.
# All docker apps take one required common parameter, `dockerImage`. This is the
# name of the container image that will be run. Additionally, any
# other app-specific parameters may be specified. Notice that all we are
# doing here is setting up local variables to receive the values passed
# in from the job
cp $appBundle ../

sh -c ../wrapper.sh
