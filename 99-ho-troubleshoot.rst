Workshop-Related Troubleshooting
================================

**Soft reset the VM supporting Docker** ``VBoxManage controlvm default reset``

**Hard reset the VM supporting Docker** ``VBoxManage controlvm default poweroff``

**Delete a failed docker-machine creation** ``docker-machine rm -f DOCKER_MACHINE_FAILED``

**Retrieve your AWS credentials** From within a **agave-cli** container, run ``metadata-list -v -Q '{"name":"iplant-aws.dib-0923.IPLANT_USERNAME"}'``

