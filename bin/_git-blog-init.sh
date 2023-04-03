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

    # Reload constants now that we can resolve $GIT_BASEDIR
    source $BINSRC/_git-blog-constants.sh

    # Now that we know the repo name, try to add a rule in robots for the bundle.
    if [ -e ./static/robots.txt ]; then
	echo "Disallow: /$1.git" >> ./static/robots.txt
    fi

    psuccess "Created new blog repo ${WHITE}$GIT_BASEDIR${NOCOLOUR}"

    pdebug "Creating S3 bucket."
    aws s3api create-bucket --bucket=$1 --region=us-east-1 2>&1 > /dev/null

    if [ $? -eq 0 ]; then
        psuccess "Created S3 bucket ${WHITE}$1${NOCOLOUR} in ${WHITE}us-east-1${NOCOLOUR}"
        write_config_attribute bucket $1
        write_config_attribute region "us-east-1"
    else
        perror "Could not create S3 bucket ${WHITE}$1${NOCOLOUR}, create bucket manually and run ${WHITE}git-blog configure upstream${NOCOLOUR}"
    fi

    configure_social
    configure_domain

    git add . 2>$1 > /dev/null
    git commit -m "Initial commit of default assets." 2>$1 > /dev/null

    psuccess "Writing configuration to ${WHITE}$CONFIG_FILE${NOCOLOUR}"
}
