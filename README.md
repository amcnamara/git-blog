Description
-----------

`git-blog` is a lightweight CMS for publishing a personal blog. It was created to satisfy a few broad goals:

- Content should be portable (decentralized and easily manageable from a new machine).
- Content should be entirely static (friendly to CDN hosting).
- Content should be *deeply archivable*.

Deeply archivable means that each revision of content is published alongside its full history, including changes to HTML/JS templating and CSS. In practice this means that all of the content is version-controlled through Git and a bundle is pushed into the CDN with each new post. The Git bundle can be used to pull down the full content history at any point, and by resetting locally a facsimile of content can be rebuilt for any commit in the past. The web has become disappointingly ephemeral over time and while the [Internet Archive](https://archive.org/) is an incredible resource I wanted to see if other approaches could be used to achieve more permanence online.

You're welcome to use and improve this tool if you like. Here are some other alternatives you should consider which can achieve many of the same goals:

- [GitHub pages](https://pages.github.com/) with [Jekyll](https://jekyllrb.com/)
- [Astro](https://astro.build/)
- [Hugo](https://gohugo.io/)


Installation
------------

This project currently only supports OSX due to some platform-specific bash utilities.

You can install locally by pulling this repo and running `make all`, it will require you to have the following packages installed on your local system:

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [MultiMarkdown](https://fletcher.github.io/MultiMarkdown-5/installation)
- [Tidy-HTML5](http://www.html-tidy.org/#homepage19700601get_tidy)
- [Mustache](https://github.com/tests-always-included/mo)
- [NPM](https://www.npmjs.com/)
- [Python3](https://www.python.org/downloads)
- [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

> NOTE: As long as `git-blog` is on your `$PATH` then `git` will find it and bind it as a subcommand.

Usage
-----

```
git blog --help                 This message
git blog init <domain>          Creates a new local blog repo, with some default assets
git blog configure [-stu]       Configures navigation links and AWS resources [default: all]
  -s --social                   Write social handles for navigation links
  -t --title                    Write title for the blog [default: domain]
  -u --upstream                 Write AWS resource locations for S3
git blog write <post-title>     Creates a new blog post
git blog build [port]           Builds all static assets into public directory, and serve for review
git blog publish                Copies built static assets to configured upstream S3 bucket
git blog doctor                 Print out system dependencies which may be missing or require updates
git blog migrate                Re-import templates and static assets
```


Getting Started
---------------

Configure the AWS CLI with a static or SSO credential:
```
aws configure
```

Initialize a new blog, this will automatically create a corresponding bucket in S3 where assets will be published:
```
git blog init example.com
```

Create a new post, and edit its contents with your default `$EDITOR` if one is defined in your shell's env:

> **NOTE**: [Markdown](https://daringfireball.net/projects/markdown/) is used as the formatting markup for post content

```
git blog write Hello World
```

Build and view the content that was just created:
```
git blog build
```

Commit the new content, and publish it:
```
git add content/posts
git commit -m "My first post."

git blog publish
```

View the contents of your S3 bucket
```
aws s3 ls example.com
```

Configure AWS to route to your content via R53 and [CloudFront](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/getting-started-cloudfront-overview.html) or [Amplify](https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-amplify.html)


Troubleshooting
---------------

Check your installed dependencies to ensure that they're up-to-date:
```
git blog doctor
```

Change the S3 bucket or region for publishing:
```
git blog configure -u
```

Clone the bundle from a published `git-blog`:
```
curl https://example.com/bundle.git > bundle
git clone bundle git-blog-backup
```
