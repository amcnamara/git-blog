export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export WHITE='\033[0;97m'
export NOCOLOUR='\033[0m'

export GIT_BASEDIR=$(git rev-parse --show-toplevel 2> /dev/null)

export CONFIG_FILE=$GIT_BASEDIR/.gitblog.cfg
export LOG_FILE=${GIT_BASEDIR:-~}/debug.log

export PUBLIC_DIR=$GIT_BASEDIR/public
export TEMPLATE_DIR=$GIT_BASEDIR/templates
export CONTENT_DIR=$GIT_BASEDIR/content
export POST_DIR=$CONTENT_DIR/posts
export STATIC_DIR=$GIT_BASEDIR/static

export OUT_INDEX_FILE=$PUBLIC_DIR/index.html
export OUT_SITEMAP_FILE=$PUBLIC_DIR/sitemap.txt
export OUT_RSS_FILE=$PUBLIC_DIR/rss.xml
export OUT_ABOUT_FILE=$PUBLIC_DIR/about.html
export OUT_POSTS=$PUBLIC_DIR/posts
export OUT_BUNDLE=$PUBLIC_DIR/bundle.git
