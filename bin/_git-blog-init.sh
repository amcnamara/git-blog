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
    export GIT_BASEDIR = $(pwd)

    echo "Copying initial resources"
    rsync -a $BINSRC/../new/ .

    # Now that we know the repo name, try to add a rule in robots for the bundle.
    if [ -e ./static/robots.txt ]; then
	echo "Disallow: /$1.git" >> ./static/robots.txt
    fi

    configure

    psuccess "Created new blog repo ${WHITE}$GIT_BASEDIR${NOCOLOUR}"
}
