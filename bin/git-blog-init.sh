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
    rsync -a $BINSRC/../new/ .
}

function clone() {
    if [ -z $1 ]; then
        echo "Argument missing: upstream git bundle"
        exit 1
    fi

    # Clone existing git-blog repo
    git clone $1
}
