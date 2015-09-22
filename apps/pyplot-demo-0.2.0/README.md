# Example Docker-based Python plot tool

1. Define DOCKER_APP_IMAGE to set the execution environment
2. Optionally, define DOCKER_DATA_IMAGE to define a static data container that will be mounted into the app container
3. Define HOST_SCRATCH to set the work directory. Defaults to /home.
4. source docker-common.sh
5. Use DOCKER_APP_RUN in your script in place of a hand-written docker command
6. You may invoke DOCKER_APP_RUN multiple times as it's actually running a docker exec inside the app container

The docker/ folder contains an example Dockerfile that uses Python's onbuild tag to automatically pull in a requirements.txt file and attempt to satisfy it. Example usage:

```
cd docker/
# edit requirements.txt
docker build --rm=true -t namespace/imagename:tag .
# push to Docker Hub on success
docker push namespace/imagename:tag
```
