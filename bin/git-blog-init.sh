function reload_constants() {
    source $BINSRC/git-blog-constants.sh
}

function initialize() {
    if [ -z $1 ]; then
        perror "Argument missing, must provide a directory name for the repo."
        exit 1
    fi
    if [ -e $1 ]; then
        perror "Directory with this name already exists."
        exit 1
    fi

    # Create new git-blog repo.
    mkdir $1
    cd $1
    git init
    echo "Copying initial resources"
    rsync -a $BINSRC/../new/ .

    reload_constants
}

function clone() {
    if [ -z $1 ]; then
        perror "Argument missing, must provide upstream git bundle."
        exit 1
    fi

    # Clone existing git-blog repo.
    git clone $1

    # TODO: Parse basename from upstream repo and change to that dir before configuring.
    repo=$1
    psuccess "Created cloned repo $repo"

    reload_constants
}
