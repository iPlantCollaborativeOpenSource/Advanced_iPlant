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

In this exercise, you will bring resources from Amazon Web Services into iPlant, run an application on them, store the results in iPlant Data Store, and share them with a friend.

Setting up your environment
---------------------------

**Preparing Docker**

First, open two UNIX terminal windows, each with access to Docker. The way you do this varies by platform:

1. If you are on **Mac or Windows and using Kitematic**, click the **[DOCKER CLI]** button two times.
2. If you are on a Mac, Windows or Linux system using **Docker Toolbox**, click the Docker Quickstart Terminal icon twice to launch the two windows
3. If you are on **Linux with Docker installed natively**, open two terminal sessions

**Launching an Agave CLI container**

Choose one (but not both) of your Docker-enabled terminal sessions. Enter the following text exactly:

``docker run -it --rm=true -v $HOME/.agave:/root/.agave -v `pwd`:/home iplantc/agave-cli bash``

This launches a container running the latest release of the iPlant flavor of the ``agave-cli``. It mounts Agave's local "cache" directory and also mounts your **current working directory** under ``/home`` inside the container.

Retrieving your AWS credentials
-------------------------------

The iPlant team has pre-created a set of credentials for each workshop attendee and stored it in the Agave document store. In the next steps, you will retrieve that information so it can be used later. If you have your own AWS credentials you'd prefer to use, you can substitute them for the ones we have provided in the following exercises.

**Query the iPlant Agave metadata service**

**Explore the AWS Console**

Using AWS S3 for storage with Agave
-----------------------------------

**Set up an Agave storageSystem**

**Upload some data**

**List the contents on your AWS bucket**

**Share a file with a friend**

Using AWS EC2 for computing with Agave
--------------------------------------

**Launch a Docker-enabled VM at AWS using Docker Machine**

``
export DEMO_VM=pick_a_name
docker-machine create --driver amazonec2 \
        --amazonec2-access-key AKIAJXPAEHZILERLYJVQ \
        --amazonec2-instance-type t2.micro  \
        --amazonec2-root-size 16  \
        --amazonec2-secret-key "4NLizA1RNVWH4IBfAVQn+7B2TojO2s0WFaGmEF81"  \
        --amazonec2-vpc-id vpc-54e81031  \
        --amazonec2-region "us-west-1" \
        --amazonec2-ami "ami-942717d1" \
        $DEMO_VM
``

**Set up your VM as an Agave executionSystem**

**Share access to your VM with a friend**

Creating an Agave application and running a job
-----------------------------------------------

An Agave application consists of:

1. A script, written in template form, that tells a remote system how to run a command on specific data
2. The physical assets that have to be installed on the remote system to enable that command. These can be binary files, reference data sets, or instructions for procuring these items.
3. Some structured metadata, posted to the Agave *apps* service that describes the system- and run-time parameters needed to run the command

Check out the following Git repository and ``cd`` into it:

``git checkout https://github.com/iPlantCollaborativeOpenSource/advanced_iplant``

