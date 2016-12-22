# Blog

This is [Dongyue Studio](http://www.dongyueweb.com)'s team blog.
Built using [ink](https://github.com/InkProject/ink).

## Installation

- [install golang](https://golang.org/doc/install)
- [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) (NOTE: install GitHub client != install git)
- config your `GOPATH` and workspace properly, remember to add `$GOPATH/bin` to your `PATH`
- install `ink` using `go get -u github.com/InkProject/ink`, this operation require `git` and `go` to be proper installed
- clone this project, ssh is preferred, i.e. `git clone git@github.com:dyweb/blog.git`

## Preview

```bash
ink preview .
```

## Deploy

```bash
./scripts/pre-deploy.sh
# push to github mannually.
```

## Create a new post

```bash
./scripts/create-post.sh
```
