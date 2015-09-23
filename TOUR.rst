Advanced iPlant: API-based data analysis
========================================

Overview
--------
iPlant offers a set of APIs, known as the Agave APIs. They allow you scriptable access to:

* Use applications published by iPlant and your colleagues
* Manage and use data in the iPlant Data Store
* Bring your own applications into iPlant
* Bring your own computing and storage resources into iPlant
* Share nearly any data or resource in iPlant with other people
* Share nearly any data or resource on your own computing and storage resources with other people

In this exercise, you will explore the iPlant Data Store, apps available on iPlant, running and managing jobs, and storing metadata.

Setting up your environment
---------------------------

**Preparing to use Docker**

First, open a UNIX terminal windows with access to Docker. The way you do this varies by platform:

1. If you are on **Mac or Windows and using Kitematic**, click the **[DOCKER CLI]** button.
2. If you are on **Mac or Windows using **Docker Toolbox**, click the Docker Quickstart Terminal icon to launch the window
3. If you are on **Linux with Docker installed natively**, open a terminal session
4. If you are on **Mac or Linux using a VM to run Linux**, follow Linux-native instructions entirely within your VM

**Launching an Agave CLI container**

In your Docker-enabled terminal session, enter the following text exactly:

``docker run -it --rm=true -v $HOME/.agave:/root/.agave -v `pwd`:/home iplantc/agave-cli bash``

This launches a container running the latest release of the iPlant flavor of the ``agave-cli``. It mounts Agave's local "cache" directory and also mounts the **current working directory** under ``/home`` inside the container. Check the contents of ``/home`` to see the contents of your host's filesystem.

Authentication
--------------

The first step in working with iPlant's APIs is to login with your iPlant credentials.  If you don't have an iPlant account or forgot your password, go to http://user.iplantcollaborative.org/. Once you have your credentials, you can begin setting up an OAuth authenticated connection with the APIs.

**Select a tenant**

The Agave API supports multiple tenants as well as multiple OAuth clients.  You first need to specify that you are using the iPlant tenant by typing the following at the command line:

``tenants-init``

You will then be prompted to select a tenant by typing in the corresponding number.  Choose "iplantc.org" as the tenant.  Executing this command will store the tenant information in the aforementioned Agave local cache directory.

**Create a client**

Like Google and many other large service providers, the iPlant APIs use the OAuth model for authentication.  This means that in addition to your username and password, you need a "client key" and "client secret".  For ecosystems with multiple services using the same authentication fabric, having client information independent from user credentials has some nice benefits, but for the purposes of this tutorial, we just need a valid client and don't really care about any other benefits.  Create your own client by typing this command at the command line:

``clients-create -S -N my-client`` 

You will be prompted for your username and password.  If successful, a new client will be created, and the key and secret will be stored in the local Agave cache.  Don't neglect to include the ``-S`` argument in the ``clients-create`` command, otherwise the client information will not be saved in the cache.  At this point, you now have a username, password, client key, and client secret.  You're ready to log in.

**Get a token**

All of the interesting things we want to do with the iPlant APIs require that you be authenticated, but rather than typing in your username and password every time you want to do something, you can log in once with our credentials and then use a "token" to prove your identity for a limited period of time afterward (usually 4 hours).  It's both convenient and in line with best security practices.  To get a token, use the ``auth-tokens-create`` command like this:

``auth-tokens-create -S``

Notice that you need to include the ``-S`` argument again so that the command line tools can store and retrieve your token from the local cache.  If successful, this command will give a long string of letters and numbers that is your token.  It will also store your token and a "refresh token" in the local cache.  At any time, you can check if you have an active token by using this command:

``auth-check``

If things went will, it will confirm that you have a token on the "iplantc.org" tenant and will show you how much time is left.  The refresh token can be used to get another token without re-entering your username and password.  When you need a new token, type:

``auth-tokens-refresh -S``

That will use your "refresh token" to attempt to retrieve a new token.  There is no harm trying it out early, either.  At this point, you should have a shiny new token, and it's time to take it for a test drive to see what it can do.

**Exercises**

- Take a peek at what is stored in the local cache by typing ``cat ~/.agave/current | python -mjson.tool``.  What information is there?  If you refresh your token using ``auth-tokens-refresh -S``, does anything change?
- Try adding the "very verbose" flag (-V) to auth-tokens-refresh.  The first line says "Calling curl".  What is curl?  (Hint: ``man curl``)


Storage and Execution Systems
-----------------------------

The iPlant APIs allow you to store data and run analyses on many different high performance systems.  To take a look at the different systems, type this command:

``systems-list``

There are quite a few systems available, and these include both storage systems dedicated to hosting data as well as execution systems that are primarily used for running analyses.  To see only the storage systems, type the following:

``systems-list -S``

The output

s3-demo-03.iplantc.org
rodeo.storage.demo
ncbi
archive.data.iplantcollaborative.org
data.iplantcollaborative.org


Data management
---------------




Launching and managing jobs
---------------------------



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
