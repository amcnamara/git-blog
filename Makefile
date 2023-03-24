SHELL := /usr/bin/env bash
.DEFAULT_GOAL := preinstall

all: preinstall install

preinstall:
	@echo -e "Checking third-party dependencies..."
	@./bin/_git-blog-helpers.sh check_dependencies
	@echo -e "\033[0;32mPreinstall complete\033[0m"

install:
	@echo -e "Installing binary and default assets..."
	@source ./bin/_git-blog-constants.sh
	@mkdir -p /usr/local/bin/git-blog
	@cp -R ./bin /usr/local/bin/git-blog
	@echo -e "\033[0;32mSuccess\033[0m: git-blog installed to /usr/local/bin/git-blog, please refer to \`\033[0;97mgit-blog --help\033[0m\` for initializing a new project."
