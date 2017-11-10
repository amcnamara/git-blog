function initialize() {
    echo "Installing node http-server..."
    npm install http-server

    echo "\nPlease enter your AWS access token:"
    read -s -e token

    echo "\nWriting token to .aws_token..."
    echo "$token" > .aws_token

    echo "\nCreating content directory..."
    mkdir -p content
    echo ./$_

    echo "\nCreating assets directory..."
    mkdir -p assets
    echo ./$_
    mkdir -p assets/layouts
    echo ./$_
    NOW=$(date +"%m%d%Y%H%M")
    touch assets/layouts/${NOW}_template.html
    echo ./$_
    mkdir -p assets/images
    echo ./$_
    mkdir -p assets/stylesheets
    echo ./$_
    touch assets/stylesheets/${NOW}_style.css
    echo ./$_
}
