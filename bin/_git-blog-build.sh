function runIndex() {
    # Read in the template block from stdin
    template=$(cat)

    # NOTE: Use arithmetic expansion to generate the sequence of post
    #       indices from 0 to n-1. The index associative array has
    #       composite keys of the form [$post,$attribute], replace all
    #       instances of post.<attribute> in the template from this map.
    for post in $(seq $((${#posts[@]} - 1))); do
        echo -e $template | sed "s/post\./index.$post,/g"
    done
}

function loadHeaderMetadata() {
    # Strip leading http[s] from domain, since it's just a label.
    export _domain=$(echo_config_attribute "domain" | sed -r "s/https?:\/\///")
    export _twitter=$(echo_config_attribute "twitter")
    export _bluesky=$(echo_config_attribute "bluesky")
    export _github=$(echo_config_attribute "github")
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

    # Find all markdown content (including siblings of the posts directory)
    content=$(find $CONTENT_DIR -name "*.md")

    if [[ ! ${content[@]} ]]; then
        pdebug "No content found to build."
        exit 1
    fi

    # NOTE: Separately from \$content, which may include other documents,
    #       find all posts and order them alphabetically. Generated posts
    #       have their creation time prepended to the filename since the
    #       file metadata is lost during cloning. Chronological ordering
    #       here is particularly important for building the index, RSS, etc.
    # TODO: File creation time is also denormalized in the post metadata,
    #       neither that attribute nor the filename are particularly robust
    #       ways of tracking a timestamp; should investigate alternatives.
    posts=$(find $POST_DIR -name "*.md")
    posts=($(ls $posts))

    # Generate an array of associated arrays by creating composite keys of
    # post offset and attribute. This is necessary because the bash version
    # of mustache (and bash itself, for that matter) doesn't support nested
    # associated arrays. These will be processed via the runIndex generator.
    local -A index=()
    for count in ${!posts[@]}; do
        post=${posts[$count]}
        for key in $(multimarkdown -m $post); do
            index[$count,$key]=$(multimarkdown -e=$key $post)
        done
    done

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

    # Render all content
    for document in $content; do
        # Find the template and corresponding output path for the given document

        midpath=$(dirname $document)
        # NOTE: Trim off parent directories from content/ upward, and leading /
        midpath=${midpath:${#CONTENT_DIR}+1}

        template=$TEMPLATE_DIR/$midpath/template.mustache
        filename=$(basename $document | cut -d. -f1 -).html
        output=$PUBLIC_DIR/$midpath/$filename

        # Ensure that the template exists for the given document
        if [ ! -e $template ]; then
            pwarning "Cannot render document, skipping due to missing template"
            echo "    document '$document'"
            echo "    expected template '$template'"
            continue
        fi

        # Ensure that public directory and midpath subdirectories exist
        if [ ! -e $PUBLIC_DIR/$midpath ]; then
            mkdir -p $PUBLIC_DIR/$midpath
        fi

        pbold "Writing $output"

        # NOTE: Due to how the bash version of mustache reads variables from
        #       the shell environment, we render all templates in a subshell
        #       to prevent post attributes from polluting sibling content.
        (
            # Read in post metadata
            for key in $(multimarkdown -m $document); do
                export $key="$(multimarkdown -e=$key $document)"
            done

            # Read in post content
            export content=$(multimarkdown --snippet $document)

            loadHeaderMetadata

            # Render post and prettify markup before writing
            mo $template | tidy --tidy-mark no --show-warnings no -i -w 0 -q - > $output
        )

        if [ $? -eq 1 ]; then
            pwarning "Encountered warnings while rendering $document"
        elif [ $? -eq 2 ]; then
            perror "Encountered errors while rendering $document"
            exit 1
        fi
    done

    # Build options (all are recommended and enabled by default in new projects, see README):
    # - Index content, ordered by creation time
    # - Sitemap of content links
    # - Generate RSS feed of content, ordered by creation time
    # - Generate Git bundle asset

    ## INDEX
    output=$PUBLIC_DIR/index.html
    template=$TEMPLATE_DIR/index.mustache

    if [ ! -e $template ]; then
        perror "Could not generate index.html, missing template $TEMPLATE_DIR/index.mustache"
        exit 1
    fi

    pbold "Writing $output"

    loadHeaderMetadata

    mo $template | tidy --tidy-mark no --show-warnings no -i -w 0 -q - > $output

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

    # Sitemaps should only contain fully qualified URLs, prefix domain if it's set.
    domain=$(echo_config_attribute "domain")

    # TODO: Validate domain against RFC-3986
    if [ -z $domain ]; then
        pwarning "Blog domain not set in config, can only generate relative URLs"
    fi

    pbold "Writing $OUT_SITEMAP_FILE"

    for path in $paths; do
        echo $domain${path#$PUBLIC_DIR} >> $OUT_SITEMAP_FILE
    done

    psuccess "Generated sitemap"

    ## RSS
    pwarning "RSS generation not yet implemented."


    ## BUNDLE
    if [ -z $(git rev-list -n 1 --all) ]; then
        pwarning "Cannot build a git bundle, no commits have been detected."
    else
        name="$PUBLIC_DIR/$(basename $GIT_BASEDIR).git"

        pbold "Writing $name"

        if git bundle create $name --all; then
            psuccess "Generated git bundle"
        else
            perror "Could not create git bundle"
        fi
    fi
}
