function cd_base() {
    while [ ! -e "./.git-blog" ]; do
	if [ $PWD == "/" ]; then
            echo "You are not in a blog directory"
            exit 1
	else
            cd ..
	fi
    done
}
