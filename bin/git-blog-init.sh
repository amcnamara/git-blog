function initialize() {
    if [ -z $1 ]; then
	echo "Argument missing: blog repo name"
	exit 1
    fi
    if [ -e $1 ]; then
	echo "Error: Directory with this name already exists"
	exit 1
    fi

    # Create repo
    mkdir $1
    cd $1
    git init
    echo "Copying initial resources"
    cp -R $BINSRC/../new/* .

    # Configure social handles
    echo "\nPlease enter your twitter handle:"
    read -e twitter
    echo "Please enter your facebook handle:"
    read -e facebook

    cat >> config.yaml <<CONF
---
twitter: $twitter
facebook: $facebook
---
CONF

    # Initialize AWS token
    echo "\nPlease enter your AWS access token:"
    read -s -e token

    if [ -z $token ]; then
        echo "No token provided, please provision $PWD/.aws_token before publishing"
    else
        echo "Writing token to $PWD/.aws_token"
        echo "Please be careful not to check-in or otherwise make this credential public!"
        echo $token > .aws_token
    fi

    echo "\nSuccessfully create new blog repo!"
    echo $PWD
    exit 0
}
