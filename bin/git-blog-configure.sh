function configure_social() {
    cd_base
    CONFIG_FILE="$PWD/config.yaml"

    # Configure social handles only if they don't already exist
    if [ -e $CONFIG_FILE ] && [ grep -q "(twitter|facebook|email)" $CONFIG_FILE]; then
	echo "WARNING: A config file with social handles already exists, please edit $CONFIG_FILE directly."
    else
	echo "Please enter your twitter handle (or leave blank):"
	read -e twitter
	echo "Please enter your facebook handle (or leave blank):"
	read -e facebook
	echo "Please enter your email address (or leave blank):"
	read -e email
	if [ -n ($twitter $facebook $email) ]
	   cat >> $CONFIG_FILE <<CONF
---
twitter: $twitter
facebook: $facebook
email: $email
---
CONF
	fi
    fi
}

function configure_upstream() {
    cd_base
    CONFIG_FILE="$PWD/config.yaml"

    # Configure blog endpoint if it isn't already present
    if [ -e $CONFIG_FILE ] && [ grep -q "location" $CONFIG_FILE]; then
	echo "WARNING: A config file with an endpoint location already exsits, please edit $CONFIG_FILE directly."
    else
	echo "Please enter the ARN of the S3 bucket where your blog is hosted:"
	read -e bucket
	if [ -n $bucket ]; then
	    cat >> $CONFIG_FILE <<CONF
---
location: $bucket
---
CONF
	fi
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
    configure_upstream
    configure_aws
}
