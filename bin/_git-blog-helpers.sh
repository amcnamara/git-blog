VERSION="1.0"
function touch_version() {
    echo "version=$VERSION" > $GIT_BASEDIR/.gitblog
}

function plumb_logs() {
    echo >> $LOG_FILE # Clear a new line
    # NOTE: "$*" is equivalent to "$@" but prints on the same line
    pdebug "$(basename $0) $*"
    exec 2>>$LOG_FILE
}

function pdebug() {
    echo -e "[${WHITE}$(date "+%h %d, %Y %H:%m:%S")${NOCOLOUR}] $1" >> $LOG_FILE
}

function is_command() {
    if command -v ${1} > /dev/null 2 >&1; then
	return 0
    fi

    return 1
}

function check_dependencies() {
    # Ensure that bash is up-to-date (OSX ships with 3.2, which doesn't
    # support the associative arrays needed for mustache templates).
    regex="bash, version ([0-9]+)"
    # NOTE: If env bash is overridden, fetch shell from script's process
    shell=$(ps -p $$ -ocomm=)

    if [[ $($shell --version) =~ $regex ]]; then
        if [[ ${BASH_REMATCH[1]} < 4 ]]; then
            perror "Bash must be greater than version 4"
            echo "Your current default shell is $(which $shell):" >&2
            echo "$($shell --version)" >&2
            exit 1
        fi
    fi

    # Ensure that the necessary commands are installed
    # NOFIX: I don't feel like using a real package manager.
    if ! is_command "git"; then
        perror "Missing 'git' source control dependency, please visit: ${WHITE}https://git-scm.com/book/en/v2/Getting-Started-Installing-Git${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "multimarkdown"; then
        perror "Missing 'multimarkdown' templating dependency, please visit: ${WHITE}http://fletcher.github.io/MultiMarkdown-5/installation${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "mo"; then
        perror "Missing 'mo' templating dependency, please visit: ${WHITE}https://github.com/tests-always-included/mo${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "aws"; then
        perror "Missing 'aws' hosting dependency, please visit: ${WHITE}http://docs.aws.amazon.com/cli/latest/userguide/installing.html${NOCOLOUR}"
        exit 1
    fi
}

function is_gitblog() {
    # Ensure that the git repo we're in is a git-blog.
    if [ ! -e "$GIT_BASEDIR/.gitblog" ]; then
        perror "You are not in a git-blog directory"
        exit 1
    fi

    touch_version
}

function echo_config_attribute() {
    # NOTE: This craps out when inlined(?).
    regex="$1:[[:blank:]]*([[:print:]]+)"

    if [[ $(cat $CONFIG_FILE) =~ $regex ]]; then
	echo ${BASH_REMATCH[1]}
    fi
}

function is_config_attribute() {
    value=$(echo_config_attribute $1)

    if [[ "true" == $(echo $value | tr '[:upper:]' '[:lower:]') ]]; then
        return 0
    fi
    return 1
}

function pbold() {
    echo -e "${WHITE}$1${NOCOLOUR}"
}

function psuccess() {
    echo -e "${GREEN}Success${NOCOLOUR}: $1"
}

function pwarning() {
    echo -e "${YELLOW}Warning${NOCOLOUR}: $1"
}

function perror() {
    echo -e "${RED}ERROR${NOCOLOUR}: $1"
    echo "       $LOG_FILE"
}

function usage() {
    cat <<USAGE
Usage:
  git-blog --help            This message
  git-blog init <name>       Creates a new local blog repo, with some default assets
  git-blog clone <target>    Creates a local copy of an existing published blog
  git-blog configure         Configures global metadata (social handles, AWS credentials, etc) on an existing blog repo
  git-blog write <title>     Creates a new blog post
  git-blog build             Builds all static assets into public
  git-blog publish           Copies static assets to target S3 bucket
USAGE
}
