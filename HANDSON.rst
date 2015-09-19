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

The iPlant team has created a set of credentials for each workshop attendee and stored it in the Agave document store. In the next steps, you will retrieve that information so it can be used later. If you have your own AWS credentials you'd prefer to use, talk to the instructors and we'll get you set up.

**Query the iPlant Agave metadata service**

In the Agave CLI window, enter the following command, substituting IPLANT_USERNAME for your own iPlant username. Pay careful attention to the use of single and double quotes!

``metadata-list -v -Q '{"name":"iplant-aws.dib-train-0923.IPLANT_USERNAME"}'``

You should get a response back that looks like this (abbreviated) JSON document:

.. code:block:: json

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
        "name": "iplant-aws.dib-train-0923.jfonner",
        "owner": "vaughn",
        "schemaId": null,
        "uuid": "0001442525546151-e0bd34dffff8de6-0001-012",
        "value": {
            "apikeys": {
                "key": "AMWIM3BEAT3BEAWT3BEA",
                "secret": "yfP3ylcmq6Syp6Syp6VPIjHxCT5v66VPIjHOTxXa"
            }
        }}]

This document contains every detail you need to interact with iPlant's AWS account. Let's take a minute to learn how to pull key bits out for use in scripting. We will use the *jq* parser, which is installed by default in the iPlant Agave CLI image.

Change into /home in the container, then pipe the document out to a file.

``cd /home && metadata-list -v -Q '{"name":"iplant-aws.dib-train-0923.jfonner"}' > my-aws-creds.json``

The resulting JSON document contains an array consisting of one object with several keys. Some of the keys have children. Here's how to extract the *iam_user*, which is your AWS login, from the document:

``jq -r .[0].value.identity.iam_user my-aws-creds.json``

You should get back ``IPLANT_USERNAME.iplantc.org``

**Exercises:**

1. Find your AWS secret and key
2. Find your IAM password
3. Find out who is the *owner* of the JSON document that was shared with you
4. What is the *uuid* of the document?
5. Bonus: Use ``metadata-pems-list`` to find out if anyone else had read permission on this document

**Explore the AWS Console**

Use iam_username and iam_password to log into https://iplant-aws.signin.aws.amazon.com/console

Using AWS S3 for storage with Agave
-----------------------------------

**Set up an Agave storageSystem**

**Upload some data**

**List the contents on your AWS bucket**

**Share a file with a friend**

Using AWS EC2 for computing with Agave
--------------------------------------

**Launch a Docker-enabled VM at AWS using Docker Machine**

.. code-block:: bash

  export IAM_KEY=*your
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
