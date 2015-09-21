# Set configuration variables for docker-common.sh
#
# Base image for the execution environment
# Basically, Python 2:latest, with matplotlib
DOCKER_APP_IMAGE='mwvaughn/python-demo:dib-0923'
# Optional data volume
DOCKER_DATA_IMAGE=''
# Only change if you need to and know what you're doing
HOST_SCRATCH='/scratch'

# **MANDATORY**
# Creates the following variables:
#
#   DOCKER_APP_RUN - exec a command inside the running app container
#   DOCKER_APP_CONTAINER - name of the running app container
#   DOCKER_DATA_CONTAINER - name of the optional data container
#
source docker-common.sh

## Script logic begins here

WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

# The application bundle is already here. We check to see if we need to unpack
# it using the boolean parameter `unpackInputs` passed in.
if [ -n "${unpackInputs}" ]; then

	# multiple datasets could be passed in, unpack each one as needed
	for i in ${dataset}; do

		dataset_extension="${i##*.}"

		if [ "$dataset_extension" == 'zip' ]; then
			unzip "$i"
		elif [ "$dataset_extension" == 'tar' ]; then
			tar xf "$i"
		elif [ "$dataset_extension" == 'gz' ] || [ "$dataset_extension" == 'tgz' ]; then
			tar xzf "$i"
		elif [ "$dataset_extension" == 'bz2' ]; then
			bunzip "$i"
		elif [ "$dataset_extension" == 'rar' ]; then
			unrar "$i"
		elif [ "$dataset_extension" != 'csv' ]; then
			echo "Unable to unpack dataset due to unrecognized file extension, ${dataset_extension}. Terminating job ${AGAVE_JOB_ID}" >&2
			${AGAVE_JOB_CALLBACK_FAILURE}
			exit
		fi

	done

fi

# Run the script with the runtime values passed in from the job request

# iterate over every input file/folder given
BASEARGS="${showYLabel} ${xlabel} ${showXLabel} ${ylabel} ${showLegend} ${height} ${width} ${background} ${format} ${separateCharts} -v"

for i in `find . -name "*.csv"`; do

    # Strip leading ./ from filenames
    i=${i#*/}
	# iterate over every chart type supplied
	for j in ${chartType}; do

		inputfile=$(basename $i)
		outdir="output/${inputfile%.*}"
		mkdir -p "$outdir"

        ARGS="$BASEARGS --output-location=$outdir --chart-type=$j $i"
		$DOCKER_APP_RUN python lib/main.py ${ARGS}

		# send a callback notification for subscribers to receive alerts after every chart is generated
		${AGAVE_JOB_CALLBACK_NOTIFICATION}

	done

done

## Script logic ends here

## -> NO USER-SERVICABLE PARTS INSIDE
if [[ -n "${DOCKER_DATA_CONTAINER}" ]];
then
    docker rm -f ${DOCKER_DATA_CONTAINER} &
fi
## <- NO USER-SERVICABLE PARTS INSIDE
