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
        "name": "iplant-aws.dib-train-0923.IPLANT_USERNAME",
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

**Explore the AWS Console**

Using your iam_username and iam_password, log into ``https://iplant-aws.signin.aws.amazon.com/console``

**Exercises:**

1. Try to look inside other people's S3 buckets. Can you? Can you look in your own?
2. Create a directory in your S3 bucket and upload a small file to it.
3. Try to inspect a running EC2 instance running. What is its public IP address?

**Check out the workshop material from Github**

The iPlant team has prepared several useful utility files and scripts to help with the objectives of the workshop. In the **agave-cli** Docker container

1. cd into **/home**
2. check out the repository ``git checkout https://github.com/iPlantCollaborativeOpenSource/Advanced_iPlant``
3. **cd into Advanced_iPlant**

You will be working out of this directory exclusively in all other parts of the workshop.

Optional: Using AWS S3 for storage with Agave
---------------------------------------------

In addition to the iPlant Data Store (data.iplantcollaborative.org), the Agave APIs let you manage data stored on other iRODS, FTP, SFTP, and gridFTP servers plus the Amazon S3 and Microsoft Azure Blob cloud providers (coming soon: support for Dropbox, Box, and Google Drive). Enrolling your data storage resources with Agave lets you easily and quickly script movement of data from site to site in your research workflow, while maintaining detailed provenance tracking of every data action you take. It also provides a unified namespace for all of your data.

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

Exercises:

1. Retrieve a detailed description of **data.iplantcollaborative.org** (hint: use the verbose option of ``systems-list``):

- What storage protocol does the iPlant Data Store use?
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

List your iPlant Data Store home directory:

``files-list IPLANT_USERNAME``

You should see all the directories and files you're used to seeing in the iPlant Discovery Environment.

List your new S3-based storage resource:

``files-list -S $S3_SYSTEM .``

What are the differences between how you list a public system like the Data Store and a private system?

Optional Exercise2:

1. Visit the `S3 Management Console <https://console.aws.amazon.com/s3/home>`_ and verify that your files were uploaded and that you can view them.
2. Re-run one or both of the ``files-list`` command with the ``-V`` verbose flag. Is there enough information returned to create a file browser-like user interface?

**Share a file with a friend**

I have shared a very sad picture with the general public: You should be able to list and download it, but go ahead and try to delete it - I dare you.

.. code-block:: bash

    files-list -S s3-demo-03.iplantc.org sadkitten.jpg
    files-get -S s3-demo-03.iplantc.org sadkitten.jpg
    files-delete -S s3-demo-03.iplantc.org sadkitten.jpg

Turn to your right, find out that person's iplant username. Share a file with them in either iDS or your S3 volume.


Using AWS EC2 for computing with Agave
--------------------------------------

**Launch a Docker-enabled VM**

Docker Machine lets you provision Docker-enabled hosts on Amazon EC2, Microsoft Azure, DigitalOcean, Google, and Rackspace commerical clouds as well as on private clouds powered by Openstack, Virtualbox, and VMware. You will use it to create one on Amazon EC2.

Set some environment variables by entering the following commands into the *second* Docker-enabled terminal (not the one running agave-cli), subsituting the appropriate values for ``DEMO_VM``, ``IAM_KEY``, and ``IAM_SECRET``.

.. code-block:: bash

  export DEMO_VM="pick_a_name"
  export IAM_KEY="Your apikeys.key"
  export IAM_SECRET="Your apikeys.secret"
  export AMI="ami-942717d1"
  export REGION="us-west-1"
  export VPC="vpc-78e7521d"

Now, in the same Docker-enabled window, enter this ``docker-machine`` command:

.. code-block:: bash

  docker-machine create --driver amazonec2 \
        --amazonec2-access-key "${IAM_KEY}" \
        --amazonec2-secret-key "${IAM_SECRET}"  \
        --amazonec2-ami "${AMI}" \
        --amazonec2-vpc-id "${VPC}"  \
        --amazonec2-region "${REGION} \
        --amazonec2-instance-type t2.micro  \
        --amazonec2-root-size 16  \
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

``git checkout https://github.com/iPlantCollaborativeOpenSource/Advanced_iPlant``
