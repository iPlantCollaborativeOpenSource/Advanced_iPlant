===============================
Advanced iPlant: The Agave APIs
===============================
Overview
--------
iPlant offers a set of APIs, known as the Agave APIs. They allow you scriptable access to:

* Use applications published by iPlant and your colleagues
* Manage and use data in the iPlant Data Store
* Bring your own applications into iPlant
* Bring your own computing and storage resources into iPlant
* Share nearly any data or resource in iPlant with other people
* Share nearly any data or resource on your own computing and storage resources with other people

In this exercise, you will bring resources from Amazon Web Services into iPlant, run an application on them, store the results in iPlant Data Store (iDS), and share them with a friend.

Setting up your environment
---------------------------

**Preparing to use Docker**

First, open **two** UNIX terminal windows, each with access to Docker. The way you do this varies by platform:

1. If you are on **Mac or Windows and using Kitematic**, click the **[DOCKER CLI]** button two times.
2. If you are on **Mac or Windows using **Docker Toolbox**, click the Docker Quickstart Terminal icon twice to launch the two windows
3. If you are on **Linux with Docker installed natively**, open two terminal sessions
4. If you are on **Mac or Linux using a VM to run Linux**, follow Linux-native instructions entirely within your VM

**Launching an Agave CLI container**

Choose one (but not both) of your Docker-enabled terminal sessions. Enter the following text exactly:

``docker run -it --rm=true -v $HOME/.agave:/root/.agave -v `pwd`:/home iplantc/agave-cli bash``

This launches a container running the latest release of the iPlant flavor of the ``agave-cli``. It mounts Agave's local "cache" directory and also mounts the **current working directory** under ``/home`` inside the container. Check the contents of ``/home`` to see the contents of your host's filesystem.

Retrieving your AWS credentials
-------------------------------

The iPlant team has created a set of credentials for each workshop attendee and stored it in the `Agave document store <http://preview.agaveapi.co/documentation/tutorials/metadata-management-tutorial/>`_. In the next steps, you will retrieve that information yo can use it later. If you have your own AWS credentials you'd prefer to use, talk to the instructors and we'll get you set up.

**Query the iPlant Agave metadata service**

In the Agave CLI window, enter the following command, **substituting IPLANT_USERNAME with your own iPlant username**. Pay careful attention to the use of single and double quotes!

``metadata-list -v -Q '{"name":"iplant-aws.dib-train-0923.IPLANT_USERNAME"}'``

You should get a response back that looks like this (abbreviated) JSON document:

.. code-block:: json

    [
    {
        "_links": {
            "self": {
                "href": "https://agave.iplantc.org/meta/v2/data/0001442525546151-e0bd34dffff8de6-0001-012"
            }
        },
        "associationIds": [],
        "created": "2015-09-17T16:32:26.151-05:00",
        "internalUsername": null,
        "lastUpdated": "2015-09-17T16:32:26.151-05:00",
        "name": "iplant-aws.dib-0923.IPLANT_USERNAME",
        "owner": "vaughn",
        "schemaId": null,
        "uuid": "0001442525546151-e0bd34dffff8de6-0001-012",
        "value": {
            "apikeys": {
                "key": "AMWIM3BEAT3BEAWT3BEA",
                "secret": "yfP3ylcmq6Syp6Syp6VPIjHxCT5v66VPIjHOTxXa"
            }
        }}]

This document contains every detail you need to interact with iPlant's AWS account. Let's take a minute to learn how to pull key bits out for use in scripting. We will use the `jq <https://stedolan.github.io/jq/tutorial/>`_ parser, which is installed by default in the iPlant Agave CLI image.

Change into /home in the container, then pipe the document out to a file.

``cd /home && metadata-list -v -Q '{"name":"iplant-aws.dib-train-0923.IPLANT_USERNAME"}' > my-aws-creds.json``

The JSON file **my-aws-creds.json** contains an array consisting of one object with several keys. Some of those keys have children. Here's how to use **jq** to extract the *iam_user*, which is your AWS username, from the document:

``jq -r .[0].value.identity.iam_user my-aws-creds.json``

You should get back ``IPLANT_USERNAME.iplantc.org``

**Exercises:**

1. Find your AWS secret and key
2. Find your IAM password
3. Find out who is the *owner* of the JSON document that was shared with you
4. What is the *uuid* of the document?
5. Bonus: Use ``metadata-pems-list`` to find out if anyone else has read permission on this document

**Check out the workshop material from Github**

The iPlant team has prepared several useful utility files and scripts to help with the objectives of the workshop. In the **agave-cli** Docker container

1. cd into **/home**
2. check out the repository ``git checkout https://github.com/iPlantCollaborativeOpenSource/Advanced_iPlant``
3. **cd into Advanced_iPlant**

You will be working out of this directory exclusively in all other parts of the workshop.

Optional: Using AWS S3 for storage with Agave
---------------------------------------------

In addition to the iDS (data.iplantcollaborative.org), the Agave APIs let you manage data stored on other iRODS, FTP, SFTP, and gridFTP servers plus the Amazon S3 and Microsoft Azure Blob cloud providers (coming soon: support for Dropbox, Box, and Google Drive). Enrolling your data storage resources with Agave lets you easily and quickly script movement of data from site to site in your research workflow, while maintaining detailed provenance tracking of every data action you take. It also provides a unified namespace for all of your data.

You will now create and exercise an Amazon S3-based storage resource, then interact with it. If you're interested in working with your own storage systems, make sure to check out the `System Management Tutorial <http://preview.agaveapi.co/documentation/tutorials/system-management-tutorial/>`_ at the Agave developer's portal.

**Set up an Agave storageSystem**

In your agave-cli Docker container window, set the following environment variables:

.. code-block:: bash

  export DEMO_S3_BUCKET="Your S3 bucket name"
  export IAM_KEY="Your apikeys.key"
  export IAM_SECRET="Your apikeys.secret"

Make sure you're in the **Advanced_iPlant** directory and run the following command from the **agave-cli container**.

``scripts/make_s3_description.sh``

This script uses the environment variables to turn a template file (``scripts/templates/systems/s3-storage.tpl``) into a functional **Agave system description**. Run without a redirect, it prints text to the screen, so you should see something resembling the following:

.. code-block:: json

    {
        "description": "Amazon S3 system owned by vaughn",
        "environment": null,
        "id": "vaughn-s3-storage",
        "name": "S3 Object Store",
        "site": "aws.amazon.com",
        "status": "UP",
        "storage": {
            "host": "s3-website-us-west-1.amazonaws.com",
            "port": 443,
            "protocol": "S3",
            "rootDir": "/",
            "homeDir": "/",
            "container": "mah_s3_bucket",
            "auth": {
                "publicKey": "AMW3BEA3IM3BEA3BEA",
                "privateKey": "yfPIjHxCT5v66VHyp6VPIjHxCT5v66VPIjHOTxXa",
                "type": "APIKEYS"
            }
        },
        "type": "STORAGE"
    }

Re-run the script, redirecting the output to a file ``scripts/make_s3_description.sh > my-s3.json``, then register the system with the Agave systems API

``systems-addupdate -v -F my-s3.json``

You should see a message like ``Successfully added system IPLANT_USERNAME-s3-storage`` (Contact an instructor if you do not!) Go ahead and set an environment variable: ``export S3_SYSTEM=IPLANT_USERNAME-s3-storage``.

**Exercises:**

1. Retrieve a detailed description of **data.iplantcollaborative.org** (hint: use the verbose option of ``systems-list``):

- What storage protocol does the iDS use?
- What kind of authentication?

2. What other public storage systems are enrolled with iPlant (hint: use the -S -P flags)
3. Can you find your new S3 system in the listing of public systems? Why not?

**Upload some data**

Upload some files from the ``scripts/assets`` directory

.. code-block:: bash

    files-upload -F scripts/assets/244.txt.utf-8 -S $S3_SYSTEM  .
    files-upload -F scripts/assets/lorem-gibson.txt -S $S3_SYSTEM .
    files-upload -F scripts/assets/images/doge.jpg -S $S3_SYSTEM .

**List the contents on your Agave storage systems**

List your iDS home directory:

``files-list IPLANT_USERNAME``

You should see the directories and files you're used to seeing in the iPlant Discovery Environment.

List your new S3-based storage resource:

``files-list -S $S3_SYSTEM .``

What are the differences between how you list a public system like the Data Store and a private system?

**Optional Exercises:**

1. Re-run one or both of the ``files-list`` command with the ``-V`` verbose flag. Is there enough information returned to create a file browser-like user interface?
2. Change the description of your S3 storage system by editing the appropriate field in ``my-s3.json`` and re-running ``systems-addupdate -F my-s3.json``. Verify that the change was effective via ``systems-list -v $S3_SYSTEM``

**Sharing data with friends**

We have shared a very sad picture with the public: You should be able to list and download it, but go ahead and try to delete it - we dare you!

.. code-block:: bash

    files-list -S s3-demo-03.iplantc.org sadkitten.jpg
    files-get -S s3-demo-03.iplantc.org sadkitten.jpg
    files-delete -S s3-demo-03.iplantc.org sadkitten.jpg

**Exercise:** Find out that a friends person's iPlant username. Share a file with them in the iDS and your S3 volume. Have them do the same. Give your friend READ_WRITE permission on a folder in your iPlant Data Store and have them upload a file. Can you see the file?

Here's an example of iPlant users **vaughn** and **jfonner** sharing some data:

.. code-block:: bash

    # vaughn grants jfonner READ access on a file in the iDS
     [vaughn@iplantc]: files-pems-update -U jfonner -P READ -S mwvaughn-s3-storage picksumipsum.txt
    # vaughn grants jfonner READ_WRITE access to a directory in iDS
     [vaughn@iplantc]: files-pems-update -U jfonner -P READ_WRITE vaughn/collab/
    # jfonner lists vaughn's files in collab
     [jfonner@iplantc]: files-list vaughn/collab/
    # jfonner views a file in vaughn/collab
     [jfonner@iplantc]: files-get -P vaughn/collab/darwin5.txt
    # jfonner grants vaughn READ access on an iDS file
     [jfonner@iplantc]: files-pems-update -U vaughn -P READ jfonner/lamarck5.txt
    # vaughn copies the file into his collab folder
     [vaughn@iplantc]: files-copy -D vaughn/collab/lamarck.txt jfonner/lamarck5.txt
    # jfonner uploads a new file to vaughn's collab folder
     [jfonner@iplantc]: files-upload -F wallace5.txt vaughn/collab/

Using AWS EC2 for computing with Agave
--------------------------------------

Agave allows you to connect to 3rd party computing resources and do work on them. These can be traditional HPC systems that are managed by schedulers such as SGE or SLURM, Condor grids (like the one the Discovery Environment uses), or simple machines that allow SSH access. This workshop focuses on a special, powerful case of the latter, a virtual machine running on Amazon EC2 with Docker installed on it. If you're interested connecting other types of computing systems, make sure to check out the `System Management Tutorial <http://preview.agaveapi.co/documentation/tutorials/system-management-tutorial/>`_ at the Agave developer's portal.

**Five Easy Steps:**

1. Launch a virtual machine on Amazon
2. Provision it with Docker support
3. Tell Agave about this new computing resource
4. Tell Agave about a simple Docker-powered application that can run on the resource
5. Run an actual compute task on the resource using Agave
6. Learn about the GUI features in the iPlant Discovery Environment that support Agave apps

**Launch a Docker-enabled VM**

Docker Machine lets you provision Docker-enabled hosts on Amazon EC2, Microsoft Azure, DigitalOcean, Google, and Rackspace commerical clouds as well as on private clouds powered by Openstack, Virtualbox, and VMware. You will use it to create one on Amazon EC2, taking care of steps 1 and 2 from the list.

Set some environment variables by entering the following commands into the *second* Docker-enabled terminal (not the one running agave-cli), subsituting the appropriate values for ``DOCKER_MACHINE_NAME``, ``IAM_KEY``, and ``IAM_SECRET``.

.. code-block:: bash

  export DOCKER_MACHINE_NAME="pick_a_name"
  export IAM_KEY="Your apikeys.key"
  export IAM_SECRET="Your apikeys.secret"
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

**Configure Docker to talk to the new host system**

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

**Set up your cloud host as an Agave executionSystem**

Congratulations: you've got Docker going in the cloud. Now, you can run just about any code on any modern Linux. Now, we need to tell Agave about your Docker host so that you can send code and data to it as part of your workflow. This solves two use cases (at least):

- You have code you'd like to make available for other people to run either via a command-line or, even better, in the iPlant Discovery Environment. Agave has some powerful abilities to make this happen.
- You need to augment your local computing by offloading some heavy stuff to a bigger machine in the cloud. Agave has some powerful abilities to make this happen, too.

In your Docker terminal window, and make sure you're cd-ed in the Advanced_iPlant directory. Run the following:

``scripts/make-docker-description.sh $DOCKER_MACHINE_NAME $IPLANT_USERNAME``

The ``make-docker-description.sh`` script uses environment variables to turn a template file (``scripts/templates/systems/execution.tpl``) into a functional **Agave system description**. Run without a redirect, it prints text to the screen, so you should see something resembling the following abbreviated example.

.. code-block:: json

    {
        "description": "Docker compute host running on amazonec2. Instance id 9d1c13733fd6a472258c32a109d8b3d3",
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

Re-run the script, redirecting the output to a file ``scripts/make-docker-description.sh $DOCKER_MACHINE_NAME $IPLANT_USERNAME > my-ec2.json``, then register the system with the Agave systems API

``systems-addupdate -v -F my-ec2.json``

You should see a message like ``Successfully added system IPLANT_USERNAME-docker-compute`` (Contact an instructor if you do not!) Go ahead and set an environment variable: ``export EC2_SYSTEM=IPLANT_USERNAME-docker-compute``.

Creating an Agave application and running a job
-----------------------------------------------

An Agave application consists of:

1. A script, written in template form, that tells a remote system how to run a command on specific data
2. The physical assets that have to be installed on the remote system to enable that command. These can be binary files, reference data sets, or instructions for procuring these items.
3. Some structured metadata, posted to the Agave *apps* service that describes the system- and run-time parameters needed to run the command

If you haven't already, in your **agave-cli** window, check out this git repository and ``cd`` into it:

``git checkout https://github.com/iPlantCollaborativeOpenSource/Advanced_iPlant``

NOTES
-----

- Implement a cloudrunner example
- Implement a more specialized version of it with parameters to run one specific program
- Send CSV from word frequency to demo-pyplot-demo-advanced-0.1.0u1
