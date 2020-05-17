GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[0;97m'
NOCOLOUR='\033[0m'

GIT_BASEDIR=$(git rev-parse --show-toplevel 2> /dev/null)
CONFIG_BASEDIR=~/.git-blog
CONFIG_FILE=$CONFIG_BASEDIR/global.cfg
LOG_FILE=${GIT_BASEDIR:-~}/debug.log

PUBLIC_DIR=$GIT_BASEDIR/public
TEMPLATE_DIR=$GIT_BASEDIR/templates
CONTENT_DIR=$GIT_BASEDIR/content
POST_DIR=$CONTENT_DIR/posts
STATIC_DIR=$GIT_BASEDIR/static

OUT_INDEX_FILE=$PUBLIC_DIR/index.html
OUT_SITEMAP_FILE=$PUBLIC_DIR/sitemap.txt
OUT_RSS_FILE=$PUBLIC_DIR/rss.xml
