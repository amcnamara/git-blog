SHELL := /usr/bin/env bash
.DEFAULT_GOAL := preinstall

all: preinstall install

preinstall:
	@./_preinstall.sh
	#./bin/_git-blog-helpers.sh check_dependencies
	# TODO: verify configs in homedir

install:
	@./_install.sh
	@mkdir -p /usr/local/bin/git-blog
	@cp -R ./bin /usr/local/bin/git-blog
	@echo -e "Success: git-blog installed to /usr/local/bin/git-blog, please refer to \`\033[0;97mgit-blog --help\033[0m\` for initializing a new project."
