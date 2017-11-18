VERSION="1.0"
function touch_version() {
    echo "version=$VERSION" > $GIT_BASEDIR/.gitblog
}

function is_command() {
    if command -v ${1} > /dev/null 2 >&1; then
	return 0
    fi

    return 1
}

function check_dependencies() {
    # Ensure that the necessary commands are installed
    # TODO: Use a package manager with real dependency management
    if ! is_command "git"; then
        perror "Missing 'git' source control dependency, please visit: ${WHITE}https://git-scm.com/book/en/v2/Getting-Started-Installing-Git${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "multimarkdown"; then
        perror "Missing 'multimarkdown' templating dependency, please visit: ${WHITE}http://fletcher.github.io/MultiMarkdown-5/installation${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "mustache"; then
        perror "Missing 'mustache' templating dependency, please visit: ${WHITE}https://www.npmjs.com/package/mustache${NOCOLOUR}"
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

function is_config_attribute() {
    # NOTE: This craps out when inlined(?).
    regex="$1:[[:blank:]]*([[:alnum:]]+)"

    if [[ $(cat $CONFIG_FILE) =~ $regex ]]; then
	if [[ "true" == $(echo ${BASH_REMATCH[1]} | tr '[:upper:]' '[:lower:]') ]]; then
	    return 0
	fi
    fi

    return 1
}

function usage() {
    cat <<EOF
Usage:
  git-blog --help            This message
  git-blog init <name>       Creates a new local blog repo, with some default assets
  git-blog clone <target>    Creates a local copy of an existing published blog
  git-blog configure         Configures global metadata (social handles, AWS credentials, etc) on an existing blog repo
  git-blog add <title>       Creates a new blog post
  git-blog build             Builds all static assets into public
  git-blog publish           Copies static assets to target S3 bucket
EOF
}

function pbold() {
    echo "${WHITE}$1${NOCOLOUR}"
}

function psuccess() {
    echo "${GREEN}Success${NOCOLOUR}: $1"
}

function pwarning() {
    echo "${YELLOW}Warning${NOCOLOUR}: $1"
}

function perror() {
    echo "${RED}ERROR${NOCOLOUR}: $1"
}
