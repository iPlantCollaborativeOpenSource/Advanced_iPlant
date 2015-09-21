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

Discover an app, run a job, get the results

apps-list -n pyplot
apps-list -v demo-pyplot-demo-advanced-0.1.0u1


In your **agave-cli** terminal window, make sure you are in ``/home/Advanced_iPlant``

-------------------------------------------
