Workshop-Related Troubleshooting
================================

**Soft reset the VM supporting Docker** ``VBoxManage controlvm default reset``

**Hard reset the VM supporting Docker** ``VBoxManage controlvm default poweroff``

**Delete a failed docker-machine creation** ``docker-machine rm -f DOCKER_MACHINE_FAILED``

**Retrieve your AWS credentials** From within a **agave-cli** container, run ``metadata-list -v -Q '{"name":"iplant-aws.dib-0923.IPLANT_USERNAME"}'``

**You see these errors**:

- ``Are you trying to connect to a TLS-enabled daemon without TLS?``
- ``Is your docker daemon up and running?``

You are not running the command in a Docker-enabled session. If on Mac/Windows use the Docker Quickstart Terminal to create a new session. If on Linux, make sure your userid is either superuser or in the docker group.

**You need to update the Agave CLI container** ``docker pull iplantc/agave-cli`` then launch ``docker run -it --rm=true -v $HOME/.agave:/root/.agave -v $HOME:/home -w /home iplantc/agave-cli bash``

