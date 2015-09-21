#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )

# set test variables
export unpackInputs=
export dataset="$DIR/lib/testdata.csv"
export chartType="line"
export xlabel="Trade Date"
export ylabel="Stock Value"
export showXLabel="--show-x-label"
export showYLabel="--show-y-label"
export showLegend="--show-legend"
export separateCharts="--file-per-series"
export height="--height=512"
export width="--width=1024"
export background="--background-color=#999999"
#export AGAVE_JOB_CALLBACK_NOTIFICATION=
#export AGAVE_JOB_CALLBACK_FAILURE=
#export AGAVE_JOB_ID=12345

# call wrapper script as if the values had been injected by the API
sh -c ../wrapper.sh
