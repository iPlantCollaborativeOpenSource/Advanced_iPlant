Creating Agave applications and running jobs
============================================

Overview
--------

A central idea behind Agave is that you can deploy any code to run anywhere on any computing system, while interacting with all the applications and data set managed by Agave's services in a unified, semantically-consistent manner using a single set of credentials. This helps to alleviate some pain points for everyday programmers, bioinformaticians and data scientists such ash:

- You have code you'd like to make available for other people to run either via a command-line or, even better, in a graphical environment like the iPlant Discovery Environment.
- You need to augment your local computing by offloading some heavy stuff to a bigger machine in the cloud.

Agave applications consists of:

1. A script, written in template form, that tells a remote system how to run a command on specific data
2. The physical assets that have to be installed on the remote system to enable that command. These can be binary files, reference data sets, or instructions for procuring these items.
3. Structured metadata, posted to the Agave *apps* service that describes the system- and run-time parameters needed to run the command

Agave jobs consist of:

1. Structured metadata, posted to the Agave *jobs* service that describes references to data that will be processed using the app, plus the system- and run-time parameters needed to run the the app.

We represent the structured metadata in JSON format, as that is what Agave services expect.

First, an example
-----------------

In your **agave-cli** terminal window, make sure you are in ``/home/Advanced_iPlant``

.. code-block:: bash
    # Find an app named pyplot
    [agave-cli:root@docker] apps-list -n pyplot
        demo-pyplot-demo-advanced-0.1.0u1
        pyplot-demo-0.2.0u2
    # View details about the app - inputs, params, etc
    [agave-cli:root@docker] apps-list -v pyplot-demo-0.2.0u2
        {"_links": {
            "executionSystem": {
                "href": "https://agave.iplantc.org/systems/v2/docker.iplantcollaborative.org"
            }...
    # Submit a job
    [agave-cli:root@docker] jobs-submit -F apps/pyplot-demo-0.2.0/demo-job.json
        Successfully submitted job 4425653391032380955-e0bd34dffff8de6-0001-007
    # Check job status. Should take ~30 sec
    [agave-cli:root@docker] jobs-status -v 4425653391032380955-e0bd34dffff8de6-0001-007
        {
            "_links": {
                "self": {
                    "href": "https://agave.iplantc.org/jobs/v2/4425653391032380955-e0bd34dffff8de6-0001-007"
                }
            },
            "id": "4425653391032380955-e0bd34dffff8de6-0001-007",
            "status": "FINISHED"
        }
    # Retrieve results
    [agave-cli:root@docker] jobs-output-get -r 4425653391032380955-e0bd34dffff8de6-0001-007 output

There should be a folder full of PNG files showing off some ancient stock price data inside the output directory. Boom - plotting as a service!

-------------------------------------------

Navigation:

- `Setting up your environment <02-ho-setup.rst>`_
- `Using AWS S3 for storage with Agave <03-ho-s3-storage.rst>`_
- `Using AWS EC2 for computing with Agave <04-ho-ec2-setup.rst>`_
- **NEXT** `Creating Agave applications and running jobs <05-ho-ec2-using.rst>`_
- `Example 1: Cloud Runner <06-cloud-runner.rst>`_
- `Example 2: An Autoscaling Cluster <07-cfncluster.rst>`_
- `Home <00-Hands-On.rst>`_
