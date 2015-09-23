Advanced iPlant: API-based data analysis
========================================

Overview
--------
iPlant offers a set of Science APIs, built on the Agave platform, that allow you scriptable access to:

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

First, open a UNIX terminal window with access to Docker. The way you do this varies by platform:

1. If you are on **Mac or Windows and using Kitematic**, click the **[DOCKER CLI]** button.
2. If you are on **Mac or Windows using Docker Toolbox**, click the Docker Quickstart Terminal icon to launch the window
3. If you are on **Linux with Docker installed natively**, open a terminal session. Make sure you are able to access Docker by typing ``docker images``
4. If you are on **Mac or Linux using a VM to run Linux**, follow Linux-native instructions entirely within the VM

**Launching an Agave CLI container**

In your Docker-enabled terminal session, enter the following text exactly:

``docker run -it --rm=true -v $HOME/.agave:/root/.agave -v $HOME:/home -w /home iplantc/agave-cli bash``

This launches a container running the latest release of the iPlant flavor of the ``agave-cli``. It mounts Agave's local "cache" directory and also mounts **your local home directory** under ``/home`` inside the container. Check the contents of ``/home`` to verify that you can see your own files and folders.

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

The output of this command should list several systems, most notably:

- **data.iplantcollaborative.org** - this is the iPlant Data Store.  Files here are also accessible through the iPlant Discovery Environment.
- **s3-demo-03.iplantc.org** - this is a demo system that we have shared with you today for this course.
- **ncbi** - this is a read-only reference to NCBI

Most interactions with data storage systems use the "files" commands that are discussed in the next session.  Next, let's look at the execution systems, but rather than just give you the command, can you figure it out?  To see what kind of arguments the ``systems-list`` command accepts, try this:

``systems-list -h``

Once you find it, run the appropriate command to only show execution systems.  Among ths systems on the list, some notable ones are:

- **lonestar4.tacc.teragrid.org** - a compute cluster at the Texas Advanced Computing Center
- **stampede.tacc.utexas.edu** - currently the 8th largest supercomputer in the world!
- **docker.iplantcollaborative.org** - mostly for demonstration and training purposes at the time of writing this, this execution host runs docker jobs.

Most interactions with execution systems are to launch jobs, but for your own systems, it is also possible to use the "files" commands to look at the local data as well.  **Note:** An execution system is always tied to a set of user credentials for that system.  In other words, when you run jobs on Stampede, there is an unprivileged iPlant service account that runs the job on your behalf and returns the results to you.  This means that iPlant can share apps with you that run on Stampede without requiring that you be able to login to Stampede directly.  If you actually have credentials that let you SSH into Stampede, you can use the ``systems-clone`` command to create your own private copy of Stampede that uses your credentials, but we won't do that in this tutorial.  Later on, we will show you how to register your own execution system.


Data management
---------------

Later on, we will do quite a bit of data movement and management.  At the moment, it is probably a good time to explore some of the files commands on your own.  Try entering the first part of the files command and hitting tab twice like this:

``files-<TAB><TAB>``

**Exercises**

- Take a few minutes to look through the different API commands that start with "files-".  Which ones do you think you will use the most?  See a description of each command by using the ``-h`` flag (e.g. ``files-upload -h``).
- Your home directory on data.iplantcollaborative.org is just your usersname.  For example, if user jfonner wanted to see what was in his home directory, he would type ``files-list /jfonner``.  Your home directory might be empty if you are new to iPlant.  Try looking at the ``/shared/iplant_training/`` directory.  Can you tell which directory was created most recently? (Hint: you will need to both pass an extra argument to "files-list" and can optionally pipe the output to another bash command for sorting)


The default iPlant storage system is data.iplantcollaborative.org, which is the iPlant Data Store.  So the following two commands are equivalent

.. code-block:: bash

    files-list /shared/iplant_training
    files-list -S data.iplantcollaborative.org /shared/iplant_training

Let's try uploading a file into your home directory.  Type in the following, substituting IPLANT_USERNAME for your actual username:

.. code-block:: bash

    echo "hello world" > demo.txt
    files-upload -F demo.txt /IPLANT_USERNAME/
    files-list /IPLANT_USERNAME/

The iPlant Discovery Environment also uses the iPlant Data Store.  In a browser window, navigate to https://de.iplantc.org and login.  Within the DE, open the "Data" window and look inside your home directory.  See ``demo.txt`` there?

Part of iPlant's goal is to let users access their data however they want.  By building on common infrastructure, command line users can collaborate with Discovery Environment users seamlessly, and users can hop between interfaces as it suits their needs.


Launching and managing jobs
---------------------------

**Apps**

Later in the workshop, we will look at registering apps and running jobs.  Here, we should just cover a few concepts. First, apps in agave are always tied to a system, and if you will recall, systems are always tied to a set of credentials.  To explore the apps that are publically available in iPlant, try this:

.. code-block:: bash

    apps-list
    apps-list -n dnasubway
    apps-list -S stampede.tacc.utexas.edu

Every app in this list has all of its binaries and dependencies packaged up on a data system (usually data.iplantcollaborative.org).  Notice that apps are also versioned, and for public apps there is also an "update" number that increments every time it is changed.  Thus, you can be assured that a given app ID (e.g. dnasubway-cuffmerge-lonestar-2.1.1u2) will always be the exact same code with the same checksum running on the same system.  It also has a JSON description of the inputs, parameters, and outputs for the app.  Though we won't deviate now to explore it, ``apps-clone`` can be used to create a personal copy of an app on an execution system that you own.

**Jobs**

The general flow for running a job often looks like the following:

.. code-block:: bash

    jobs-template -A bowtie2-2.2.4_aligner-2.2.4u1 > bowtie-job.json
    # edit bowtie-job.json 
    jobs-submit -F bowtie-job.json
    jobs-list
    jobs-history 0123456789012345678-0123456789abcde-0001-007
    jobs-output-list 0123456789012345678-0123456789abcde-0001-007

We will actually do this later on, for now let's just look at the commands available to us:

- jobs-template - **experimental**. This command attempts to parse an app description and create a template for running a job against that app.  It is dependent on how the app was integrated, so it may require more or less editing to do what you want.
- jobs-submit - Once you have a job submission JSON file, you can submit it with this command.
- jobs-list - Shows a list of past jobs you have initiated and their status
- jobs-history - Gives you detailed information about a specific job.
- jobs-output-list - Locates the output from the job and lists the contents.

If you haven't run any Agave jobs before, ``jobs-list`` may be empty for you.  Conversely, if you have run "HPC" jobs in the Discovery Environment before, you will also see a record of them here.

**Exercises**
- Take a few minutes to look at what goes into an example FastQC app with this command: ``apps-list -v dnasubway-fastqc-lonestar-0.11.2.0u2``
- Why do you think the APIs use JSON to describe apps and run jobs (and most other things)?


Summary
-------

There are a lot of features we have covered, and honestly quite a few we haven't explored yet, but hopefully this gives you a rough idea of how to explore the CLI tools and the underlying API.
