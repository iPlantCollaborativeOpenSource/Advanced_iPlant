Creating and using Agave applications
=====================================

Switch to your **other Docker Terminal window (**not agave-cli**), then go to the source directory for this workshop ``cd $HOME/Advanced_iPlant/apps/wordfrequency-0.1.0``

Develop and test code locally using Docker
------------------------------------------

iPlant staff have written a simple Python application that counts word-length frequencies in a text file. The code is in ``lib/main.py``. By adapting the workflow we are demonstrating, you can  develop and test your own Docker-based scientific codes. Launch ``main.py --help`` to read its help (and test that the Docker setup is working OK) by entering the Docker run command below. It should print a help screen (perhaps after pulling the ``mwvaughn/python-demo`` image).

.. code-block:: bash

    [localhost] docker run -it --rm=true -v $HOME/.agave:/root/.agave -v `pwd`:/home -w /home mwvaughn/python-demo:dib-0923 python lib/main.py --help

    usage: main.py [-h] --filename INPUTFILE [--max MAX_LENGTH]
                   [--allow-digits ALLOW_DIGITS] [--ignore IGNORE_LIST]

    Perform word-length frequency analysis on a document.

    optional arguments:
      -h, --help            show this help message and exit
      --filename INPUTFILE, -f INPUTFILE
                            Text file to parse.
      --max MAX_LENGTH, -m MAX_LENGTH
                            The maximum word length to count. Default is 32.
      --allow-digits ALLOW_DIGITS, -d ALLOW_DIGITS
                            Allow digits to be parsed (true/false). Default is
                            false.
      --ignore IGNORE_LIST, -i IGNORE_LIST
                            Comma-delimted list of words to ignore

Run the main.py script with some arguments:

.. code-block:: bash

    [localhost] docker run -it --rm=true -v $HOME/.agave:/root/.agave -v `pwd`:/home -w /home mwvaughn/python-demo:dib-0923 python lib/main.py --filename data/174.txt.utf-8
    Analysing 'data/174.txt.utf-8'
    Computing stats...
    Printing results to data/174-stats-20150922-201332.csv

Confirm that an output file was be placed in ``data/``, then experiment with the various options presented in the help: ``--max, --ignore, --allow-digits`` to get a feel for how to run ``main.py``

Templates, tests, and app descriptions
--------------------------------------

To adapt this code for use by the Agave apps service, a script template and application description must be created. The ones for wordfrequency-0.1.0 will be discussed below:

**Script Template** Examine two files inside ``wordfrequency-0.1.0`` side by side: ``wrapper-fillmein.sh`` and ``wrapper.sh``. The latter is a fully-fleshed out Agave script template, while the former is a more generic example. To go from generic to working template, you need to specify:

- The image name and tag from Docker Hub that supports code execution
- The image name and tag from Docker Hub to provide a data container (optional)
- Some Bash shell logic to dynamically create an argument string
- The executable and any local assets to be invoked

**Test script** A key aspect of Agave's job execution lifecycle is that it substitutes provided in a job description into the wrapper template file to create a script that is executed on the remote host. We can simulate this behavior by exporting variables and letting Bash do the work for us. Examine ``test.sh`` and ``wrapper.sh`` side-by-side and notice how Bash variable substitution will turn the wrapper into real, runnable Bash script.

**Let's try it out!** Making sure you're still in ``$HOME/Advanced_iPlant/apps/wordfrequency-0.1.0``, enter ``bash test.sh`` and watch the exciting ``wordfrequency`` action ensue. As before, it should print results into the ``data`` directory.

**App Description** Now, look at ``app.json`` it is the metadata that will be provided to Agave to tell it how to tell USERS how invoke instances of the application. It can also be used by graphical clients like the iPlant Discovery Environment to create a basic user interface for submitting compute jobs. Here are some notable points:

- The ``id`` fields of each element in ``inputs`` and ``parameters`` corresponds to a variable in ``wrapper.sh``
- In all but ``allow_digits``, it is specified that ``showArgument`` is ``true`` and the ``argument`` field maps to one that ``main.py`` is expecting
- There is a JSON ``type`` associated with each input and parameter that advertise what kind of values are expected. There's also a ``validator`` regular expression, which we've left ``null`` in most cases. These allow both Agave and any front-end clients to pre-validate user-specified values, which in turn helps prevent frustrating user error.

Publishing the application
--------------------------

You need access to the Agave CLI for this part, so **switch to the Terminal running agave-cli** and ``cd /home/iPlant/Advanced_iPlant/apps``. Notice that you're actually one directory level up from ``wordfrequency-0.1.0``. The sequence of events is as follows:

- Set a couple environment variables to make scripting easier
- Create ``my-app.json``, a copy of `app.json`` tailored to your iPlant username and AWS-based execution system
- Upload the application bundle to the iPlant Data Store
- Register the tailored ``my-app.json`` with the Agave Apps service
- Create a ``my-job.json``, a copy of ``job.json`` tailored to your newly published app
- Run your test job and inspect the outputs

.. code-block:: bash

    # All the environment variables
    export IPLANT_USERNAME=$(auth-check | grep username | awk '{print $2}')
    export AGAVE_EXEC_SYSTEM="sub_in_your_ec2_system_name"

    # Upload the application bundle to the iPlant Data Store
    # Any time you make changes to the wrapper script or other assets
    # in this directory, you must re-upload it for them to take effect
    #
    files-upload -F wordfrequency-0.1.0 $IPLANT_USERNAME/applications/

    # Create a custom app description
    ../scripts/make_custom_app.sh wordfrequency-0.1.0/templates/app.jsonx > my-app.json

    # Wait about 30 seconds to be sure the files-upload from above has completed
    # In the meantime, look at the values for name, deploymentPath, and executionSystem
    # in the my-app.json file
    # Publish the application metadata to the Agave apps service
    apps-add-update -F my-app.json

    # You should get a response
    # Successfully added app IPLANT_USERNAME-wordfrequency-0.1.0
    export APP_ID=IPLANT_USERNAME-wordfrequency-0.1.0

    # Create a custom test job
    ../scripts/make_custom_job.sh $APP_ID wordfrequency-0.1.0/templates/job.jsonx > my-job.json

    # Submit it to test it out
    # You should get a response like
    # Successfully submitted job 83863804664606235-e0bd34dffff8de6-0001-007
    # where the latter string of numbers and digits is JOB_ID
    jobs-submit -F my-job.json

    # Monitor it for completion. When jobs-status is FINISHED move on
    jobs-status JOB_ID

    # Grab the results
    # Will create a folder job-JOB_ID which you can inspect the contents of
    jobs-output-get -r JOB_ID

**Exercises**

1. Plot the results from your wordfrequency job using the pyplot application

More Resources
--------------

Building Agave applications can be very rewarding way to share your code with your colleagues and the world. This is a very simple example. If you are interested to learn more, please check out the `App Management Tutorial <http://preview.agaveapi.co/documentation/tutorials/app-management-tutorial/>`_ on the Agave Developer Portal.

- `Setting up your environment <02-ho-setup.rst>`_
- `Using AWS S3 for storage with Agave <03-ho-s3-storage.rst>`_
- `Using AWS EC2 for computing with Agave <04-ho-ec2-setup.rst>`_
- `Discovering and using Agave Applications <05-ho-ec2-using.rst>`_
- `Creating and using Agave applications <06-ho-make-app.rst>`_
- **NEXT** `Synergy with the iPlant Discovery Environment <07-ho-discoenv.rst>`_
- `Home <00-Hands-On.rst>`_
- `Example 1: Cloud Runner <20-cloud-runner.rst>`_
- `Example 2: An Autoscaling Cluster <21-cfncluster.rst>`_
- `Troubleshooting <99-ho-troubleshoot.rst>`_
