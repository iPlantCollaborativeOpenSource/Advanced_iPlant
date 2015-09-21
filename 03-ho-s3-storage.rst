Using AWS S3 for storage with Agave
===================================

Overview
--------

In addition to the iDS (data.iplantcollaborative.org), the Agave APIs let you manage data stored on other iRODS, FTP, SFTP, and gridFTP servers plus the Amazon S3 and Microsoft Azure Blob cloud providers (coming soon: support for Dropbox, Box, and Google Drive). Enrolling your data storage resources with Agave lets you easily and quickly script movement of data from site to site in your research workflow, while maintaining detailed provenance tracking of every data action you take. It also provides a unified namespace for all of your data.

You will create and exercise an Amazon S3-based storage resource, then interact with it. If you're interested in working with your own storage systems, make sure to check out the `System Management Tutorial <http://preview.agaveapi.co/documentation/tutorials/system-management-tutorial/>`_ at the Agave developer's portal.

Set up an Agave storageSystem
-----------------------------

The iPlant team has already created an Amazon S3 bucket for your use. You can find its name in the metadata record we shared with you under ``value.aws.s3``. The bucket name is the part after ``s3://``

In your **agave-cli** window, set the following environment variables:

.. code-block:: bash

  export DEMO_S3_BUCKET="Your S3 bucket name"
  export IAM_KEY="Your apikeys.key"
  export IAM_SECRET="Your apikeys.secret"
  export IPLANT_USERNAME=$(auth-check | grep username | awk '{print $2}')

Make sure you're in the **/home/Advanced_iPlant** directory and run the following command:

``scripts/make_s3_description.sh``

This script uses the environment variables you just set to turn a template file (``scripts/templates/systems/s3-storage.tpl``) into a functional **Agave system description**. Run without a redirect, it prints text to the screen, so you should see something resembling the following:

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
                "publicKey": "AMW3B..BEA3BEA",
                "privateKey": "yfPIjHxCT5..VPIjHOTxXa",
                "type": "APIKEYS"
            }
        },
        "type": "STORAGE"
    }

Re-run the script, redirecting the output to a file ``scripts/make_s3_description.sh > my-s3.json``, then register the system with the Agave systems API

``systems-addupdate -v -F my-s3.json``

You should see a message like ``Successfully added system IPLANT_USERNAME-s3-storage`` (Contact an instructor if you do not!) Go ahead and set an environment variable: ``export S3_SYSTEM=IPLANT_USERNAME-s3-storage`` making sure to substitute in your iPlant username where appropriate.

**Exercises:**

1. List the storage systems ``systems-list -S`` - do you see your S3 system there?
2. Retrieve a detailed description of **data.iplantcollaborative.org** (hint: use the verbose option of ``systems-list``):

- What storage protocol does the iDS use?
- What kind of authentication?

2. What other public storage systems are enrolled with iPlant (hint: use the -S -P flags for ``systems-list``)
3. Is your new S3 system in the listing of **public** systems? Why not?

Store some data
---------------

Now that you have at least two places to store data (iPlant Data Store and Amazon S3), you can learn a bit about storing and sharing data. This is covered exhaustively in the Agave `Data Management Tutorial <http://preview.agaveapi.co/documentation/tutorials/data-management-tutorial/>`_ online elsewhere.

Upload the following files from the ``/home/Advanced_iPlant`` directory:

.. code-block:: bash

    files-upload -F scripts/assets/244.txt.utf-8 -S $S3_SYSTEM  .
    files-upload -F scripts/assets/lorem-gibson.txt -S $S3_SYSTEM .
    files-upload -F scripts/assets/images/doge.jpg -S $S3_SYSTEM .
    files-upload -F scripts/assets/images/TheKesselRun.jpg -S data.iplantcollaborative.org $IPLANT_USERNAME

List the contents of your Agave storage systems
-----------------------------------------------

List your iDS home directory:

``files-list $IPLANT_USERNAME``

You should see the directories and files you're used to seeing in the iPlant Discovery Environment.

List your new S3-based storage resource:

``files-list -S $S3_SYSTEM .``

What are the differences between how you list a public system like the Data Store and a private system?

**Optional Exercises:**

1. Re-run one or both of the ``files-list`` command with the ``-V`` verbose flag. Is there enough information returned to create a file browser-like user interface?
2. Change the description of your S3 storage system by editing the appropriate field in ``my-s3.json`` and re-running ``systems-addupdate -F my-s3.json``. Verify that the change was effective via ``systems-list -v $S3_SYSTEM``

Share data with your friends
----------------------------

The iPlant team has shared a very sad picture with the public: You should be able to see and download it, but go ahead and try to delete it - we dare you!

.. code-block:: bash

    files-list -S s3-demo-03.iplantc.org sadkitten.jpg
    files-get -S s3-demo-03.iplantc.org sadkitten.jpg
    files-delete -S s3-demo-03.iplantc.org sadkitten.jpg

Here's an example of iPlant users **vaughn** and **jfonner** sharing some data:

.. code-block:: bash

    # vaughn grants jfonner READ access on a file in the iDS
     [vaughn@iplantc]: files-pems-update -U jfonner -P READ -S mwvaughn-s3-storage picksumipsum.txt
    # vaughn grants jfonner READ_WRITE access to his collab directory in iDS
     [vaughn@iplantc]: files-pems-update -U jfonner -P READ_WRITE vaughn/collab/
    # jfonner lists vaughn's files in collab/
     [jfonner@iplantc]: files-list vaughn/collab/
    # jfonner views a file in vaughn/collab/
     [jfonner@iplantc]: files-get -P vaughn/collab/darwin5.txt
    # jfonner grants vaughn READ access on an iDS file
     [jfonner@iplantc]: files-pems-update -U vaughn -P READ jfonner/lamarck5.txt
    # vaughn copies the file into his collab folder
     [vaughn@iplantc]: files-copy -D vaughn/collab/lamarck.txt jfonner/lamarck5.txt
    # jfonner uploads a new file to vaughn's collab folder
     [jfonner@iplantc]: files-upload -F wallace5.txt vaughn/collab/

**Exercises:**

1. Find out a friends person's iPlant username. Share ``doge.jpg`` with them on your S3 system. Have them do the same on their system. Can you see each other's shared files via ``files-list -S SYSTEM .``?
2. Give your friend READ_WRITE permission on a folder in your iPlant Data Store and have them upload a file to it. Can you see the file with a ``files-list``?

Navigation:

- `Setting up your environment <02-ho-setup.rst>`_
- `Using AWS S3 for storage with Agave <03-ho-s3-storage.rst>`_
- **NEXT** `Using AWS EC2 for computing with Agave <04-ho-ec2-setup.rst>`_
- `Creating Agave applications and running jobs <05-ho-ec2-using.rst>`_
- `Example 1: Cloud Runner <06-cloud-runner.rst>`_
- `Example 2: An Autoscaling Cluster <07-cfncluster.rst>`_
- `Home <00-Hands-On.rst>`_
