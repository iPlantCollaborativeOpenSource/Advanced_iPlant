{
    "description": "Amazon S3 system owned by %AGAVE_USERNAME",
    "environment": null,
    "id": "%AGAVE_SYSTEM_NAME",
    "name": "S3 Object Store",
    "site": "aws.amazon.com",
    "status": "UP",
    "storage": {
        "host": "s3-website-us-west-1.amazonaws.com",
        "port": 443,
        "protocol": "S3",
        "rootDir": "/",
        "homeDir": "/",
        "container": "%AWS_BUCKET_NAME",
        "auth": {
            "publicKey": "%AWS_ACCESS_KEY",
            "privateKey": "%AWS_SECRET_KEY",
            "type": "APIKEYS"
        }
    },
    "type": "STORAGE"
}
