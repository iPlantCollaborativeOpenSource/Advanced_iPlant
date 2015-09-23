Using AWS EC2 for computing with Agave
======================================

Overview
--------

Agave allows you to connect to 3rd party computing resources and do work on them. These can be traditional HPC systems that are managed by schedulers such as SGE or SLURM, Condor grids (like the one the Discovery Environment uses), or simple machines that allow SSH access. This workshop focuses on a special, powerful case of the latter, a virtual machine running on Amazon EC2 with Docker installed on it. If you're interested connecting other types of computing systems, make sure to check out the `System Management Tutorial <http://preview.agaveapi.co/documentation/tutorials/system-management-tutorial/>`_ at the Agave developer's portal.

**Five Easy Steps:**

1. Launch a virtual machine on Amazon
2. Provision it with Docker support
3. Tell Agave about this new computing resource
4. Tell Agave about a simple Docker-powered application that can run on the resource
5. Run an actual compute task on the resource using Agave
6. Learn about the GUI features in the iPlant Discovery Environment that support Agave apps

Launch a Docker-enabled VM
--------------------------

Docker Machine lets you provision Docker-enabled hosts on Amazon EC2, Microsoft Azure, DigitalOcean, Google, and Rackspace commerical clouds as well as on private clouds powered by Openstack, Virtualbox, and VMware. You will use it to create one on Amazon EC2, taking care of steps 1 and 2 from the list.

Set some environment variables by entering the following commands into the *second* Docker-enabled terminal (not the one running agave-cli), subsituting the appropriate values for ``DOCKER_MACHINE_NAME``, ``IAM_KEY``, and ``IAM_SECRET``. Remember that you can find your credentials in ``~/my-aws-creds.json``

.. code-block:: bash

  export DOCKER_MACHINE_NAME="pick_a_name_make_it_unix_friendly"
  export IPLANT_USERNAME="your_iplant_username_here"
  export IAM_KEY="your_aws_key"
  export IAM_SECRET="your_aws_secret"
  export REGION="us-west-1"
  export VPC="vpc-54e81031"

Now, in same Docker window, enter this ``docker-machine`` command:

.. code-block:: bash

  docker-machine create --driver amazonec2 \
        --amazonec2-access-key "${IAM_KEY}" \
        --amazonec2-secret-key "${IAM_SECRET}"  \
        --amazonec2-vpc-id "${VPC}"  \
        --amazonec2-region "${REGION}" \
        $DOCKER_MACHINE_NAME

The ``docker-machine`` command will run for a while and then you should see:

``Launching instance...
To see how to connect Docker to this machine, run: docker-machine env DOCKER_MACHINE_NAME``

Configure Docker to talk to the new VM
--------------------------------------

Each Docker Machine system has its own configuration, which you can retrieve at any time with the ``env`` command. Here's what it looked like on the instructor's machine - yours should look similiar.

.. code-block:: bash

    docker-machine env $DOCKER_MACHINE_NAME
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://54.215.249.202:2376"
    export DOCKER_CERT_PATH="/Users/mwvaughn/.docker/machine/machines/vaughn-docker"
    export DOCKER_MACHINE_NAME="vaughn-docker"
    # Run this command to configure your shell:
    # eval "$(docker-machine env vaughn-docker)"

Part of the beauty of Docker Machine is that it lets you treat a remote host, like the one you just created, as though it were a local system. To do that, you must re-configure your local Docker client to point outwards.

``eval "$(docker-machine env $DOCKER_MACHINE_NAME)"``

**Note**: To switch back to your local Docker installation, run ``eval "$(docker-machine env default)"``

**Launch some containers on your new system**

The basic syntax for the following Docker commands is

``docker run [options] [image:tag] [(optional) command]``

**Note**: The ``-it --rm=true`` tells Docker to launch an interactive container with an attached terminal, and to remove the container when it exits. The ``command`` at the end is optional - many Docker images have a default command defined that runs when the container launches. If you don't provide a command, Docker will attempt to execute it instead.

Run the following example Docker commands. For each of the following examples after the ``hello-world`` case, typing Control-D will exit the container.

.. code-block:: bash

    # Launch the Docker test image. Prints out some nice debugging info and quits
    docker run -it --rm=true hello-world
    # Launch a bash shell running on Centos 5.11
    docker run -it --rm=true centos:5.11 bash
    # Check the version of Centos. Welcome to Legacyville - Population: 1
    cat /etc/redhat-release
    # Launch a Python 2.7 interpreter
    docker run -it --rm=true python:2.7 python
    # Launch the latest Python version
    docker run -it --rm=true python:latest python

**Exercises:**

1. Run another command using one of the same containers. An example might be ``docker run -it --rm=true centos:5.11 uptime``. How much of a delay did you experience before the results of your custom command were returned?
2. List the Docker images on the remote system - are any them familiar?
3. Look up details about the centos image at `Docker Hub <https://hub.docker.com/>`_. How many other versions of Centos are supported via public Docker images?

Set up your cloud host as an Agave executionSystem
--------------------------------------------------

Congratulations: you've got Docker going in the cloud. Your code portability and scaling problems are coming to an end. Now, we need to tell Agave about your Docker host so that you can send code and data to it as part of your workflow. In your Docker terminal (not the agave-cli) window, and make sure you're cd-ed in the Advanced_iPlant directory. Run the following:

``scripts/make-exec-docker.sh $DOCKER_MACHINE_NAME $IPLANT_USERNAME``

The ``make-exec-docker.sh`` script uses environment variables to turn a template file (``scripts/templates/systems/execution.tpl``) into a functional **Agave system description**. Run without a redirect, it prints text to the screen, so you should see something resembling the following abbreviated example.

.. code-block:: json

    {
        "description": "Docker compute host running on amazonec2. Instance id 9d1c13733fd2258c32a109d8b3d3",
        "environment": null,
        "executionType": "CLI",
        "id": "vaughn-docker-compute",
        "login": {
            "auth": {
                "username": "ubuntu",
                "publicKey": "ssh-rsa AAAAB3Nz..RvWJYx4hz",
                "privateKey": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpA..eg==\n-----END RSA PRIVATE KEY-----",
                "type": "SSHKEYS"
            },
            "host": "54.215.249.202",
            "port": 22,
            "protocol": "SSH"
        }
    }

Re-run the script, redirecting the output to a file ``scripts/make-exec-docker.sh $DOCKER_MACHINE_NAME $IPLANT_USERNAME > my-ec2.json``, then register the system with the Agave systems API

``systems-addupdate -v -F my-ec2.json``

You should see a message like ``Successfully added system IPLANT_USERNAME-docker-compute`` (Contact an instructor if you do not!)

Go ahead and set an environment variable: ``export AGAVE_EXEC_SYSTEM=IPLANT_USERNAME-docker-compute`` (you know what to do with **IPLANT_USERNAME**,right?)

**Exercises:**

1. Modify the description of your compute system by editing ``my-ec2.json``, then posting the updated description to Agave with ``systems-addupdate -F my-ec2.json``.
2. Retrieve a detailed listing of ``stampede.tacc.utexas.edu`` and ``condor.opensciencegrid.org``. What is the executionType (hint: Try ``jq -r .executionType``) for each, and how is that different from your Docker system?

Navigation:

- `Setting up your environment <02-ho-setup.rst>`_
- `Using AWS S3 for storage with Agave <03-ho-s3-storage.rst>`_
- `Using AWS EC2 for computing with Agave <04-ho-ec2-setup.rst>`_
- **NEXT** `Discovering and using Agave Applications <05-ho-ec2-using.rst>`_
- `Creating and using Agave applications <06-ho-make-app.rst>`_
- `Synergy with the iPlant Discovery Environment <07-ho-discoenv.rst>`_
- `Home <00-Hands-On.rst>`_
- `Example 1: Cloud Runner <20-cloud-runner.rst>`_
- `Example 2: An Autoscaling Cluster <21-cfncluster.rst>`_
- `Troubleshooting <99-ho-troubleshoot.rst>`_
