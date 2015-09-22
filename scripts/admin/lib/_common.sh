
warning () {

    _message=$1
    echo -e "\x1B[31mWarning: ${_message}\x1B[0m"
}

failure () {

    _message=$1
    echo -e "\x1B[3;41mFailure: ${_message}\x1B[0m"
    exit 1
}

success () {

    _message=$1
    echo -e "\x1B[32mSuccess: ${_message}\x1B[0m"
}

log () {

    _message=$1
    echo -e "\x1B[1m${_message}\x1B[0m"

}

AWS_CLI=$(which aws)
if [[ -z "$AWS_CLI" ]];
then
    failure "Please install and configure the \x1B[1mAWS cli\x1B[0m"
fi
