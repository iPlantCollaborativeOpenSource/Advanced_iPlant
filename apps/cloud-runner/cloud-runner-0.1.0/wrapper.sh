#set -x

# force std out and std err to go to the respective files.
exec 2> ${AGAVE_JOB_NAME}.err 1> ${AGAVE_JOB_NAME}.out

# This is a generic wrapper script for running docker containers.
# All docker apps take one required common parameter, `dockerImage`. This is the
# name of the container image that will be run. Additionally, any
# other app-specific parameters may be specified. Notice that all we are
# doing here is setting up local variables to receive the values passed
# in from the job

DOCKER_IMAGE="${dockerImage}"

# The application bundle is already here. We check to see if we need to unpack
# it using the flag parameter `unpackInputs` passed in.

if [ -n "${unpackInputs}" ]; then
	APP_BUNDLE="${appBundle}"
	app_bundle_extension="${APP_BUNDLE##*.}"

	if [ "$app_bundle_extension" == 'zip' ]; then
	  unzip "$APP_BUNDLE"
	elif [ "$app_bundle_extension" == 'tar' ]; then
	  tar xf "$APP_BUNDLE"
	elif [ "$app_bundle_extension" == 'gz' ] || [ "$app_bundle_extension" == 'tgz' ]; then
	  tar xzf "$APP_BUNDLE"
	elif [ "$app_bundle_extension" == 'bz2' ]; then
	  bunzip "$APP_BUNDLE"
	elif [ "$app_bundle_extension" == 'rar' ]; then
	  unrar "$APP_BUNDLE"
	else
		echo "Unable to unpack application bundle due to unknown compression extension .${extension}. Terminating job ${AGAVE_JOB_ID}" >&2
	  ${AGAVE_JOB_CALLBACK_FAILURE}
		exit
	fi
fi

# This is the command inside the container to invoke when running the job
# for example,
#COMMAND='Rscript'
COMMANDS="${command}"

# This is the arguments to the container command. For example,
#COMMAND_ARGS='main.r'
COMMAND_ARGS="${commandArgs}"

# If a Dockerfile is included in the app bundle, it will be built prior
# to execution. Additonally, the `dockerFile` input variable could be
# provided which will result in the same behavior. If given, the docker file will
# be used to build the app. It is important not to include the binary's
# execution as a RUN step in the Dockerfile as this will cause it to be run
# twice.

if [ -e Dockerfile ]; then
	time -p docker build -rm -t "$DOCKER_IMAGE" .

	# Fail the job if the build fails
	if [ ! $? ]; then
		echo "Failed to build Dockerfile. Terminating job ${AGAVE_JOB_ID}" >&2
		${AGAVE_JOB_CALLBACK_FAILURE}
		exit
	fi

	# replace the given image with the job id so we know we execute the correct container
	DOCKER_IMAGE=${AGAVE_JOB_ID}

fi

# Fail the job if the build fails
if [ -z "$DOCKER_IMAGE" ]; then
	echo "No Docker image specified or provided. Terminating job ${AGAVE_JOB_ID}" >&2
	${AGAVE_JOB_CALLBACK_FAILURE}
	exit
fi

# Run the container in docker, mounting the current job directory as /scratch in the container
# Note that here the docker container image must exist for the container to run. If it was
# not built using a passed in Dockerfile, then it will be downloaded here prior to
# invocation. Also note that all output is written to the mounted directory. This allows
# Agave to stage out the data after running.

docker run -i --rm -v `pwd`:/scratch -w /scratch $DOCKER_IMAGE ${COMMANDS} ${COMMAND_ARGS}

if [ $? -ne 0 ]; then
	echo "Docker process exited with an error status." >&2
	${AGAVE_JOB_CALLBACK_FAILURE}
	exit
fi

# Good practice would suggest that you clean up your image after running. For throughput
# you may want to leave it in place. iPlant's docker servers will clean up after themselves
# using a purge policy based on size, demand, and utilization.

#sudo docker rmi $DOCKER_IMAGE
