function configure_social() {
    cd_base
    CONFIG_FILE="$PWD/config.yaml"

    # Configure social handles only if the don't already exist
    if [ -e $CONFIG_FILE ] && [ grep -q "(twitter|facebook)" $CONFIG_FILE]; then
	echo "WARNING: A config file with social handles already exists, please edit $CONFIG_FILE directly."
    else
	echo "Please enter your twitter handle:"
	read -e twitter
	echo "Please enter your facebook handle:"
	read -e facebook
	cat >> $CONFIG_FILE <<CONF
---
twitter: $twitter
facebook: $facebook
---
CONF
    fi
}

function configure_aws() {
    cd_base

    # Initialize AWS token
    echo "Please enter your AWS access token:"
    read -s -e token

    if [ -z $token ]; then
        echo "No token provided, please provision $PWD/.aws_token before publishing"
    else
        echo "Writing token to $PWD/.aws_token"
        echo "Please be careful not to check-in or otherwise make this credential public!"
        echo $token > .aws_token
    fi
}

function configure() {
    configure_social
    configure_aws
}
