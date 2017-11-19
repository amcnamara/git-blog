function reload_constants() {
    source $BINSRC/_git-blog-constants.sh
}

function initialize() {
    if [ -z $1 ]; then
        perror "Argument missing, must provide a directory name for the repo"
        exit 1
    fi
    if [ -e $1 ]; then
        perror "Directory with this name already exists"
        exit 1
    fi

    # Create new git-blog repo.
    mkdir $1
    cd $1
    git init
    echo "Copying initial resources"
    rsync -a $BINSRC/../new/ .

    reload_constants
    configure

    psuccess "Created new blog repo ${WHITE}$GIT_BASEDIR${NOCOLOUR}"
}

function clone() {
    if [ -z $1 ]; then
        perror "Argument missing, must provide upstream git bundle"
        exit 1
    fi

    # Parse repo name out of bundle name:
    # - If a URL or bath is provided drop everything until the last /
    # - If the bundle filename ends with .git strip it out
    repo=${1##*\/}
    repo=${repo%\.git}

    # Clone an existing git-blog repo.
    git clone $1 $repo

    cd $repo
    reload_constants

    psuccess "Created cloned repo $repo"
}
