function plumb_logs() {
    if [ -e "$LOG_FILE" ]; then
        # Clear a new line if a log file already exists.
        echo >> $LOG_FILE
    fi
    # NOTE: "$*" is equivalent to "$@" but prints on the same line
    pdebug "$(basename $0) $*"
    exec 2>>$LOG_FILE
}

function is_command() {
    if command -v ${1} > /dev/null 2 >&1; then
        return 0
    fi

    return 1
}

function check_dependencies() {
    plumb_logs $@
    # Ensure that bash is up-to-date (OSX ships with 3.2, which doesn't
    # support the associative arrays needed for mustache templates).
    #
    # TODO: Might be able to support 3.2 if the hash of values can be
    #       encoded into local variables with a dynamic naming scheme,
    #       ex: $var__<$key>="value" and replaced at runtime. Just need
    #       to ensure it won't pollute the context of other templates.
    #       Note that ${!var__*} can be used to enumerate over variable
    #       attributes in the context with this naming convention, ex:
    #       for key in ${!var__*}; do
    #         value=${!$key}
    #       done
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
        perror "Missing 'multimarkdown' templating dependency, please visit: ${WHITE}https://fletcher.github.io/MultiMarkdown-5/installation${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "tidy"; then
        perror "Missing 'tidy-html5' HTML formatter dependency, please visit: ${WHITE}http://www.html-tidy.org/#homepage19700601get_tidy${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "mo"; then
        perror "Missing 'mo' templating dependency, please visit: ${WHITE}https://github.com/tests-always-included/mo${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "python3"; then
        perror "Missing 'python3' runtime, please visit: ${WHITE}https://www.python.org/downloads${NOCOLOUR}"
        exit 1
    fi

    if ! is_command "aws"; then
        perror "Missing 'aws' hosting dependency, please visit: ${WHITE}http://docs.aws.amazon.com/cli/latest/userguide/installing.html${NOCOLOUR}"
        exit 1
    fi
}

function show_dependency_versions() {
    plog "Git version $(pbold $(git --version | sed 's/^[^[:digit:]]*\(.*\)/\1/g')) (recommended $(pbold '>=2.40.0'))"
    plog "MultiMarkdown version $(pbold $(multimarkdown --help | grep "MultiMarkdown v\d.\d.\d" | cut -d' ' -f2 | cut -c2-)) (recommended $(pbold '>=6.6.0'))"
    plog "Tidy-HTML5 version $(pbold $(tidy --version | sed 's/^[^[:digit:]]*\(.*\)/\1/g')) (recommended $(pbold '>=5.8.0'))"
    plog "Mo version $(pbold $(mo --help | grep "MO_VERSION=" | cut -d'=' -f2)) (recommended $(pbold '>=3.0.7'))"
    plog "Python3 version $(pbold $(python3 --version | cut -d' ' -f2)) (recommended $(pbold '>=3.12.7'))"
    plog "AWS CLI version $(pbold $(aws --version | cut -d' ' -f1 | cut -d'/' -f2)) (recommended $(pbold '>=2.18.0'))"
}

function is_gitblog() {
    # Ensure that the git repo we're in is a git-blog.
    if [ ! -e "$CONFIG_FILE" ]; then
        perror "You are not in a git-blog directory"
        exit 1
    fi
}

function echo_config_attribute() {
    if [[ ! $1 ]]; then
        pwarning "Attempting to read config attribute, but no attribute key provided"
        return
    fi

    # NOTE: This craps out when inlined(?).
    regex="$1=[[:blank:]]*([[:print:]]+)"

    if [[ $(cat $CONFIG_FILE) =~ $regex ]]; then
        plog "${BASH_REMATCH[1]}"
    fi
}

function write_config_attribute() {
    if [[ ! $1 ]]; then
        perror "Attempting to write or clear config attribute, but no attribute key provided"
        exit 1
    fi

    # NOTE: For some reason this craps out in-line
    match="s/$1=.*/$1=${@:2}/"
    sed -i '' -e "$match" $CONFIG_FILE
}

function plog() {
    echo -e "$1"
}

function pbold() {
    plog "${WHITE}$1${NOCOLOUR}"
}

function psuccess() {
    plog "${GREEN}Success${NOCOLOUR}: $1"
}

function pwarning() {
    # Print warns to both the stdout and stderr (which plumbs through to
    # the debug file). In this case use process substitution to redirect
    # the output of the process to stderr since the file descriptor on OSX
    # isn't consistent with other linux distributions.
    plog "${YELLOW}Warning${NOCOLOUR}: $1" | tee >(cat >&2)
}

function perror() {
    plog "${RED}ERROR${NOCOLOUR}: $1" | tee >(cat >&2)
    plog "\t$LOG_FILE"
}

function pdebug() {
    plog "[${WHITE}$(date "+%h %d, %Y %H:%M:%S")${NOCOLOUR}] $1" >> $LOG_FILE
}

function usage() {
    cat <<USAGE
Usage:
  git-blog --help                 This message
  git-blog init <domain>          Creates a new local blog repo, with some default assets
  git-blog configure [-stu]       Configures navigation links and AWS resources [default: all]
    -s --social                   Write social handles for navigation links
    -t --title                    Write title for the blog [default: domain]
    -u --upstream                 Write AWS resource locations for S3
  git-blog write <post-title>     Creates a new blog post
  git-blog build [port]           Builds all static assets into public directory, and serve for review
  git-blog publish                Copies built static assets to configured upstream S3 bucket
  git-blog doctor                 Print out system dependencies which may be missing or require updates
  git-blog migrate                Re-import templates and static assets
USAGE
}
