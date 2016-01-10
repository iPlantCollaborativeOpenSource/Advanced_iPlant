Advanced Cyverse: Deploying simple-to-use scalable workflows using the Agave API
================================================================================

Overview
--------
Cyverse offers a set of REST APIs, built on the Agave platform, that give you scriptable access to:

* Use applications published by Cyverse and your colleagues
* Manage and use data in the Cyverse Data Store
* Bring your own applications into Cyverse
* Bring your own computing and storage resources into Cyverse
* Share nearly any data or resource in Cyverse with other people
* Share nearly any data or resource on your own computing and storage resources with other people

In this demo, we will interact with the Cyverse Data Store and view apps available at Cyverse. We will then run and monitor a PacBio FALCON job and retrieve the results.

Installing the CLI
------------------

The Agave CLI is a collection of Bash shell scripts allowing you to interact with the Agave Platform. It allows you to streamline common interactions with the API and automate repetitive and/or background tasks. The following dependencies are required to use the Agave API CLI:

	* bash
	* curl
	* python (2.7.1+)

Simply clone the *foundation-cli* repository from Bitbucket and add its *bin* directory to your PATH and you're ready to go. You may want to make that PATH edit permanent by adding it to your .bashrc or or .profile file.

.. code-block:: bash

  git clone https://bitbucket.org/taccaci/foundation-cli.git agave-cli
	export PATH=$PATH:`pwd`/agave-cli/bin

From here on, we assume you have the CLI installed and your environment configured properly. We also assume you either set or will replace the following environment variables:

* `AGAVE_USERNAME`: The username you use to login to Cyverse/Cyverse
* `AGAVE_PASSWORD`: The password you use to login to Cyverse/Cyverse

Authentication
--------------

The first step in working with Cyverse's APIs is to login with your Cyverse credentials.  If you don't have an Cyverse account or forgot your password, go to http://user.iplantcollaborative.org/. Once you have your credentials, you can begin setting up an OAuth authenticated connection with the APIs.

**Select a tenant**

The Agave API supports multiple tenants as well as multiple OAuth clients.  You first need to specify that you are using the Cyverse tenant by typing the following at the command line:

``tenants-init``

You will then be prompted to select a tenant by typing in the corresponding number.  Choose "iplantc.org" as the tenant.  Executing this command will store the tenant information in the aforementioned Agave local cache directory. You will only need to do this the first time you download and configure the Agave CLI on any particular computer.

**Create an Oauth client**

Like Google and most other software-as-a-service providers, the Cyverse APIs use the OAuth model for authentication.  This means that in addition to your username and password, you need a "client key" and "client secret".  For ecosystems with multiple services using the same authentication fabric, having client information independent from user credentials has some nice benefits, but for the purposes of this tutorial, we just need a valid client and don't really care about those other benefits.  Create your own client by typing this command at the command line:

``clients-create -S -N my-client``

You will be prompted for your username and password.  If successful, a new client will be created, and the key and secret will be stored in the local Agave cache.  Don't neglect to include the ``-S`` argument in the ``clients-create`` command, otherwise the client information will not be saved in the cache.  At this point, you now have a username, password, client key, and client secret.  You're ready to log in for the first time.

**Get a token**

All of the interesting things we want to do with the Cyverse APIs require that you be authenticated, but rather than typing in your username and password every time you want to do something, you can log in once with our credentials and then use a "token" to prove your identity for a limited period of time afterward (usually 4 hours).  It's both convenient and in line with best security practices.  To get a token, use the ``auth-tokens-create`` command like this:

``auth-tokens-create -S``

Notice that you need to include the ``-S`` argument again so that the command line tools can store and retrieve your token from the local cache.  If successful, this command will give a long string of letters and numbers that is your token.  It will also store your token and a "refresh token" in the local cache.  At any time, you can check if you have an active token by using this command:

``auth-check``

If things went well, it will confirm that you have a token on the "iplantc.org" tenant and will show you how much time is left.  The refresh token can be used to get another token without re-entering your username and password.  When you need a new token, type:

``auth-tokens-refresh -S``

That will use your "refresh token" to attempt to retrieve a new token.  There is no harm trying it out early, either.  At this point, you should have a shiny new token, and it's time to take it for a test drive to see what it can do.

**Exercises**

- Take a peek at what is stored in the local cache by typing ``cat ~/.agave/current | python -mjson.tool``.  What information is there?  If you refresh your token using ``auth-tokens-refresh -S``, does anything change?
- Try adding the "very verbose" flag (-V) to auth-tokens-refresh.  The first line says "Calling curl".  What is curl?  (Hint: ``man curl``)

Storage and Execution Systems
-----------------------------

The Cyverse APIs allow you to store data and run analyses on many different high performance systems.  To take a look at the different systems, type this command:

``systems-list``

There are quite a few systems available, and these include both storage systems dedicated to hosting data as well as execution systems that are primarily used for running analyses.  To see only the storage systems, type the following:

``systems-list -S``

The output of this command should list several systems, most notably:

- **data.iplantcollaborative.org** - this is the Cyverse Data Store.  Files here are also accessible through the Cyverse Discovery Environment.
- **ncbi** - this is a read-only reference to

Most interactions with data storage systems use the "files" commands that are discussed in the next session.  Next, let's look at the execution systems, but rather than just give you the command, can you figure it out?  To see what kind of arguments the ``systems-list`` command accepts, try this:

``systems-list -h``

Once you find it, run the appropriate command to only show execution systems.  Among the systems on the list, some notable ones are:

- **lonestar4.tacc.teragrid.org** - a compute cluster at the Texas Advanced Computing Center
- **stampede.tacc.utexas.edu** - currently the 8th largest supercomputer in the world!
- **docker.iplantcollaborative.org** - this execution host runs Docker jobs. Mostly for demonstration and training purposes for now.

Most interactions with execution systems are to launch jobs, but for your own systems, it is also possible to use the "files" commands to look at the local data as well.  **Note:** An execution system is always tied to a set of user credentials for that system.  In other words, when you run jobs on Stampede, there is an unprivileged Cyverse service account that runs the job on your behalf and returns the results to you.  This means that Cyverse can share apps with you that run on Stampede without requiring that you be able to login to Stampede directly.  If you actually have credentials that let you SSH into Stampede, you can use the ``systems-clone`` command to create your own private copy of Stampede that uses your credentials, but we won't do that in this tutorial.  You can also bring your OWN systems into the Agave API, but that's outside the scope of this simple tour.

Data management
---------------

You likely do quite a bit of data movement and management.  So, it is probably a good time to explore some of the Agave files commands.  If we enter the first part of the files command and hit tab twice like this, we will see many file commands.

``files-<TAB><TAB>``

**Exercises**

- Take a few minutes to look through the different API commands that start with "files-".  Which ones do you think you will use the most?  See a description of each command by using the ``-h`` flag (e.g. ``files-upload -h``).
- Your home directory on data.iplantcollaborative.org is just *your username*.  For example, if user jfonner wanted to see what was in his home directory, he would type ``files-list /jfonner``.  Your home directory might be empty if you are new to Cyverse. Let's look in the ``/shared/iplant_training/`` directory.

``files-list -L shared/iplant_training/```

Which directory was created most recently?

The default Cyverse storage system is data.iplantcollaborative.org, which is the Cyverse Data Store.  Thus, the following two commands are equivalent:

.. code-block:: bash

    files-list /shared/iplant_training
    files-list -S data.iplantcollaborative.org /shared/iplant_training

Let's try uploading a file into your home directory.  Type in the following, substituting IPLANT_USERNAME for your actual username:

.. code-block:: bash

    echo "hello world" > demo.txt
    files-upload -F demo.txt /IPLANT_USERNAME/
    files-list /IPLANT_USERNAME/

The Cyverse Discovery Environment also uses the Cyverse Data Store.  In a browser window, navigate to https://de.iplantc.org and login.  Within the DE, open the "Data" window and look inside your home directory.  See ``demo.txt`` there?

Part of Cyverse's goal is to let users access their data however they want.  By building on common infrastructure, command line users can collaborate with Discovery Environment users seamlessly, and users can hop between interfaces as it suits their needs.


Launching and managing jobs
---------------------------

**Apps**

To explore the apps that are publically available in Cyverse, you can use apps-list or apps-search

.. code-block:: bash

    apps-list
    apps-list -S stampede.tacc.utexas.edu -l 5
    # SQL-like query terms
    apps-search 'name.like=*dnasubway*' 'limit=10' 'public=true'
    apps-list -v FALCON-0.4.2

Every app in this list has all of its binaries and dependencies packaged up on a data system (usually data.iplantcollaborative.org).  Notice that apps are also versioned, and for public apps there is also an "update" number that increments every time it is changed.  Thus, you can be assured that a given app ID (e.g. dnasubway-cuffmerge-lonestar-2.1.1u2) will always be the exact same code with the same checksum running on the same system.  It also has a JSON description of the inputs, parameters, and outputs for the app.

**Jobs**

Let's submit a FALCON job from the CLI

.. code-block:: bash

    jobs-template -A FALCON-0.4.2 > FALCON-0.4.2-job.jsonX
    # Edit FALCON-0.4.2-job.jsonX to add input files, etc and save it as FALCON-0.4.2-job.json
    # Submit it to the Agave jobs service
    jobs-submit -F FALCON-0.4.2-job.json -W

You can skip the -W watch flag and submit the job asychronously. If you do so, you may monitor the job's progress via status and history. You may also use notifications in your job to set up HTTP or email callbacks to notify you of the job's progress through its lifecycle.

.. code-block:: bash

    jobs-status JOBID
    jobs-history JOBID

Each of these can be invoked with the -v flag to return a detailed, parseable JSON response.

While this is running, let's go look at how Agave interacts with the Cyverse DE...

To conclude the demo, let's view or download the FALCON results:

.. code-block:: bash

    # List the job outputs
    jobs-output-list JOBID
    # Download the entire job output directory
    jobs-output-get -r $JOBID
    # Download a specific file
    jobs-output-get -r $JOBID PATH
    # View a specific file on screen
    jobs-output-get -P JOBID myerrorfile.err

