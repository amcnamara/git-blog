Installation
------------

To run this project, the following dependencies need to be available locally:

- https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- https://fletcher.github.io/MultiMarkdown-5/installation
- http://www.html-tidy.org/#homepage19700601get_tidy
- https://github.com/tests-always-included/mo
- http://docs.aws.amazon.com/cli/latest/userguide/installing.html

To validate dependencies and install git-blog:

```
./configure
make all
```

> NOTE: Ensure that `/usr/local/bin` is on the `$PATH`

Usage
-----

| | |
| - | - |
| `git-blog init <name>`      | Creates a new local blog repo, with some default assets.
| `git-blog clone <target>`   | Creates a local copy of an existing published blog.
| `git-blog configure`        | Configures global metadata (social handles, AWS credentials, etc) on an existing blog repo.
| `git-blog write <title>`    | Creates a new blog post.
| `git-blog build`            | Builds all static assets into public.
| `git-blog publish`          | Copies static assets to target S3 bucket.
| | |