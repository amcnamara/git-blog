SHELL := /usr/bin/env bash
.DEFAULT_GOAL := preinstall

all: preinstall install

preinstall:
	@echo -e "Checking third-party dependencies..."
	@source ./bin/_git-blog-constants.sh && source ./bin/_git-blog-helpers.sh check_dependencies
	@echo -e "\033[0;32mAll dependencies are installed\033[0m"
	@echo -e "Dependency version recommendations:\n"
	@source ./bin/_git-blog-constants.sh && source ./bin/_git-blog-helpers.sh show_dependency_versions
	@echo -e "\n\033[0;32mPreinstall complete\033[0m"

install:
	@echo -e "Installing binary and default assets..."
	@rm -rf /usr/local/opt/git-blog
	@mkdir -p /usr/local/opt/git-blog
	@cp -R ./bin ./new /usr/local/opt/git-blog
	@mkdir -p /usr/local/opt/git-blog/new/content/posts
	@ln -s -f /usr/local/opt/git-blog/bin/git-blog /usr/local/bin/git-blog
	@source ./bin/_git-blog-constants.sh && source ./bin/_git-blog-helpers.sh pull_npm_puppeteer
	@echo -e "\033[0;32mSuccess\033[0m: git-blog installed to /usr/local/bin/git-blog, please refer to \`\033[0;97mgit-blog --help\033[0m\` for initializing a new project."
