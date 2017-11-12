function cd_base() {
    while [ ! -e "./.git-blog" ]; do
	if [ $PWD == "/" ]; then
            echo "You are not in a git-blog directory"
            exit 1
	else
            cd ..
	fi
    done
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
