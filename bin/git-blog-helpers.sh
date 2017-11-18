VERSION="1.0"
function touch_version() {
    echo "version=$VERSION" > $GIT_BASEDIR/.gitblog
}

function is_gitblog() {
    # Ensure that the git repo we're in is a git-blog.
    if [ ! -e "$GIT_BASEDIR/.gitblog" ]; then
	echo "${RED}ERROR${NOCOLOUR}: You are not in a git-blog directory."
	exit 1
    fi
}


function is_config_attribute() {
    # NOTE: This craps out when inlined(?).
    regex="$1:[[:blank:]]*([[:alnum:]]+)"

    if [[ $(cat $GIT_BASEDIR/config.yaml) =~ $regex ]]; then
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
