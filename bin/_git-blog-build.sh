function generateKeywordLinks() {
    keywords=(${index[$1,keywords]})
    for i in "${!keywords[@]}"; do
        echo -e "<$2>#${keywords[i]}</$2>"
    done
}

function friendlyDate() {
    # Convert from RFC 5322 to a friendlier format.
    echo $(date -jf "%a, %d %b %Y %H:%M:%S %z" "$1" +"%b %-d, %Y")
}

function injectYearHeader() {
    # Fetch the publication year of the current and previous posts from the index.
    curr=$(date -jf "%a, %d %b %Y %H:%M:%S %z" "${index[$1,publish_date]}" +"%Y")
    prev=$(date -jf "%a, %d %b %Y %H:%M:%S %z" "${index[$(($1 + 1)),publish_date]}" +"%Y")

    if [ -z $curr ]; then
        # Posts in progress
        echo "<h4>Not Published</h4>"
    elif [ -z $prev ] || [ $prev -gt $curr ]; then
        # If the above post is from a different year, inject the header for the current year.
        echo "<h4>$curr</h4>"
    fi
}

function loadHeaderMetadata() {
    export _domain=$(echo_config_attribute "domain")
    export _title=$(echo_config_attribute "title")
    export _bundle=$(basename $OUT_BUNDLE)
    export _github=$(echo_config_attribute "github")
    export _bluesky=$(echo_config_attribute "bluesky")
    export _twitter=$(echo_config_attribute "twitter")
    export _facebook=$(echo_config_attribute "facebook")
}

function build() {
    # Bail out if we're in public/ or one of its subdirectories.
    #
    # NOTE: If the script is run from the public directory it will get
    #       into a strange state where the terminal becomes orphaned,
    #       since part of the build step involves removing that directory.
    if [[ $PWD == $PUBLIC_DIR* ]]; then
        perror "Cannot run build from within $PUBLIC_DIR, run from $GIT_BASEDIR"
        exit 1
    fi
        
    # Blow away all existing built assets, and copy in all static assets
    rm -rf $PUBLIC_DIR
    rsync -a $STATIC_DIR/* $PUBLIC_DIR

    # NOTE: Sketchy as hell
    source mo

    # Read global metadata into the environment, since the bash version of
    # mustache unfortunately pulls template attributes from env variables.
    OLDIFS=$IFS
    IFS==
    while read -r key value; do
        if [ ! -e $value ]; then
            export $key=$value
        fi
    done < $CONFIG_FILE
    IFS=$OLDIFS

    loadHeaderMetadata

    domain=$(echo_config_attribute 'domain')

    # TODO: Validate domain against RFC-3986
    if [ -z $domain ]; then
        pwarning "Blog domain not set in config, can only generate relative URLs"
    else
        # Sitemaps should only contain fully qualified URLs, so prefix the domain.
        domain="https://$domain"
    fi

    ## ABOUT
    output=$PUBLIC_DIR/about.html
    template=$TEMPLATE_DIR/about.mustache
    title="About me"

    if [ ! -e $template ]; then
        pwarning "Could not generate about.html, missing template $TEMPLATE_DIR/about.mustache"
    else
        # Read in post content
        export content=$(multimarkdown --snippet "$GIT_BASEDIR/about.md")

        if [ -z "$content" ]; then
            pwarning "Could not generate about.html, missing content $GIT_BASEDIR/about.md"
        else
            pbold "Writing $output"

            # Used to toggle profile in navigation
            export _about=1
            mo --allow-function-arguments $template | tidy --tidy-mark no --show-warnings no -i -w 0 -q - > $output

            psuccess "Generated about page."
        fi
    fi


    ## POSTS
    # Find all markdown content (including siblings of the posts directory)
    posts=(`echo $(find $POST_DIR -name "*.md" | sort)`)

    if [[ ! ${posts[@]} ]]; then
        perror "No post content found to build."
        exit 1
    fi

    # This will hold all post metadata and content used for rendering the main
    # index page, it is generated alongside post rendering, see below.
    local -A index=()

    for count in ${!posts[@]}; do
        document=${posts[$count]};

        # Generate an array of associated arrays by creating composite keys of
        # post offset and attribute. This is necessary because the bash version
        # of mustache (and bash itself, for that matter) doesn't support nested
        # associated arrays. These will be processed via the runIndex generator.
        for key in $(multimarkdown -m $document); do
            index[$count,$key]=$(multimarkdown -e=$key $document)
        done

        # Read in post content
        export content=$(multimarkdown --snippet $document)

        # Create a checksum to act as a post GUID for the RSS feed. This
        # is not intendid to be a mechanism to establish content trust.
        index[$count,'guid']=`echo "$(basename $document)$content" | md5sum | cut -d' ' -f1`

        template=$TEMPLATE_DIR/posts/template.mustache
        output=$OUT_POSTS/$count.html

        # Ensure that the template exists for the given document
        if [ ! -e $template ]; then
            pwarning "Cannot render document, skipping due to missing template"
            pbold "\tdocument '$document'"
            pbold "\texpected template '$template'"
            continue
        fi

        # Ensure that public directory and midpath subdirectories exist
        if [ ! -e $OUT_POSTS ]; then
            mkdir -p $OUT_POSTS
        fi

        pbold "Writing $document to: $output"

        # NOTE: Due to how the bash version of mustache reads variables from
        #       the shell environment, we render all templates in a subshell
        #       to prevent post attributes from polluting sibling content.
        (
            # Read in post metadata
            for key in $(multimarkdown -m $document); do
                export $key="$(multimarkdown -e=$key $document)"
            done

            loadHeaderMetadata

            # Pre-render page if needed
            if [ $(multimarkdown -e=build-opts $document | grep -i -E "pre\-?render") ]; then
                export _prerender="true"
            fi

            # Render post and prettify markup before writing
            mo --allow-function-arguments $template | tidy --tidy-mark no --show-warnings yes -i -w 0 -q - > $output

            # Pre-render page if needed
            if [ -v _prerender ]; then
                pre_render $output
            fi
        )

        if [ $? -eq 1 ]; then
            pwarning "Encountered warnings while rendering $document"
        elif [ $? -eq 2 ]; then
            perror "Encountered errors while rendering $document"
            exit 1
        fi
    done

    psuccess "Generated post content"


    ## INDEX
    output=$PUBLIC_DIR/index.html
    template=$TEMPLATE_DIR/index.mustache
    title="Index"

    if [ ! -e $template ]; then
        perror "Could not generate index.html, missing template $TEMPLATE_DIR/index.mustache"
        exit 1
    fi

    pbold "Writing $output"

    export postIndicies=(`seq $((${#posts[@]} - 1)) 0`)

    mo --allow-function-arguments $template | tidy --tidy-mark no --show-warnings yes -i -w 0 -q - > $output

    if [ $? -eq 1 ]; then
        pwarning "Encountered warnings while rendering index"
    elif [ $? -eq 2 ]; then
        perror "Encountered errors while rendering index"
        exit 1
    else
        psuccess "Generated index"
    fi

    ## SITEMAP
    # Lookup all public markup, including both generated and copied static pages.
    paths=$(find $PUBLIC_DIR -name '*.html')

    pbold "Writing $OUT_SITEMAP_FILE"

    for path in $paths; do
        echo $domain${path#$PUBLIC_DIR} >> $OUT_SITEMAP_FILE
    done

    psuccess "Generated sitemap"


    ## RSS
    template=$TEMPLATE_DIR/rss.mustache
    _buildtime=$(date -R)

    pbold "Writing $OUT_RSS_FILE"

    mo --allow-function-arguments $template > $OUT_RSS_FILE

    psuccess "Generated RSS feed"


    ## BUNDLE
    if [ -z $(git rev-list -n 1 --all) ]; then
        pwarning "Cannot build a git bundle, no commits have been detected."
    else
        pbold "Writing $OUT_BUNDLE"

        if git bundle create $OUT_BUNDLE --all; then
            psuccess "Generated git bundle"
        else
            perror "Could not create git bundle"
        fi
    fi
}
