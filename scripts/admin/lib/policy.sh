attach_policy () {

local _USER=$1
local _GROUP=$2
local _S3=$3

log "Attaching policy to ${_GROUP}/${_USER}..."
RESPONSE=

# This is way too permissive. Don't grant them access to the console!
sh -c "cat > Policy.json" <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:*",
          "Resource": "*"
        }
    ]
}
EOT

RESPONSE=$(aws iam put-user-policy --user-name ${_USER} --policy-name "${_USER}.access" --policy-document file://Policy.json)

rm -rf Policy.json

}