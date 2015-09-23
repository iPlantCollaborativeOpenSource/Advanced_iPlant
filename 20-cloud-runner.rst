Application Example: Cloud Runner
=================================

iPlant has published an proof-of-concept application called **cloud-runner** which offers, essentially, Docker as a service. It is integrated with **agave-cli** via the ``jobs-run-this`` command. This, in combination with the **jobs-outputs-get** command allows you to write code locally, then transparently run it on a cloud host. The iPlant cloud-runner is hosted on a modest VM, but in theory, you could copy and publish cloud-runner onto an extremely resource-rich host, giving you a way to cloud-burst your computation.

cloud-runner requires just N parameters:

- dockerImage: The Docker image to run against
- command: The actual command to run inside the Docker container
- commandArgs: Arguments to pass to the command
- unpackInputs: Automatically try to unpack any compressed files before running

However, the best way to interact with cloud-runner is via the CLI command, because it adds some really awesome functionality. Essentially, it packs up the entire local directory and ships it off to cloud-runner.

For a demonstration, inside your *agave-cli* container:

.. code-block:: bash

    cd /home/Advanced_iPlant/apps/cloud-runner/test/
    auth-tokens-refresh -S
    # jobs-run-this -h will explain the command syntax
    jobs-run-this -I "agaveapi/scipy-matplot-2.7" -c "python" "main.py"

You should then see a log resembling this one:

.. code-block:: bash

    Verifying Docker image agaveapi/scipy-matplot-2.7 exists...
    Found image agaveapi/scipy-matplot-2.7 in Docker central index
    Compressing /Users/mwvaughn/src/iPlant/Advanced_iPlant/apps/cloud-runner...
    Creating remote staging directory...
    Uploading compressed work directory...
    Uploading vaughn-runner-14429844133N.tgz...
    ######################################################################## 100.0%
    Submitting job...
    Successfully submitted job 127760363290684955-e0bd34dffff8de6-0001-007

You can monitor the status of the job and download its results when status = FINISHED

.. code-block:: bash

    jobs-status 127760363290684955-e0bd34dffff8de6-0001-007
    RUNNING
    jobs-status 127760363290684955-e0bd34dffff8de6-0001-007
    FINISHED
    jobs-outputs-get -r 127760363290684955-e0bd34dffff8de6-0001-007

And then look at the results in job-127760363290684955-e0bd34dffff8de6-0001-007/*.out

.. code-block:: bash

    less job-127760363290684955-e0bd34dffff8de6-0001-007/*.out
    Hello, Python

How friendly!

**Exercises:**

1. Write an R, Python, or Perl script that does something to a data file in the local directory and run it using the job runner. Hint: If you use standard file extensions for your scripts (.R, .py, etc.) the job runner detects that and will try to guess the executable and image. For example, ``jobs-run-this "main.py"`` will work the same as the more verbose invocation from above.
2. Deploy cloud-runner to your AWS EC2 system and run a job on it. We've included template/apps.jsonx for you

From an **agave-cli** container...

.. code-block:: bash

    auth-tokens-refresh -S
    export IPLANT_USERNAME=$(auth-check | grep username | awk '{print $2}')
    export AGAVE_EXEC_SYSTEM="sub_in_your_ec2_system_name"
    cd /home/Advanced_iPlant/apps/cloud-runner/

    # Refresh your credentials, upload your assets
    files-upload -F cloud-runner-0.1.0 $IPLANT_USERNAME/applications/

    # Create a custom application template
    ../../scripts/make_custom_app.sh cloud-runner-0.1.0/templates/app.jsonx > my-cloud-runner.json

    # Register it with Agave apps
    apps-add-update -F my-cloud-runner.json
    # You should get back (with your username)
    # Successfully added app IPLANT_USERNAME-runner-0.1.0

    # jobs-run-this -h will explain the command syntax
    cd test
    jobs-run-this -I "agaveapi/scipy-matplot-2.7" -c "python" "main.py"

    # Check status...
    jobs-status JOBID_FROM_ABOVE
    # When status = FINISHED
    jobs-output-get -r JOBID_FROM_ABOVE

