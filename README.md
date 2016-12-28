# Blog

[![Build Status](https://travis-ci.org/dyweb/blog.svg)](https://travis-ci.org/dyweb/blog)

This is [Dongyue Studio](http://www.dongyueweb.com)'s [team blog](http://blog.dongyueweb.com/).
Built using [ink](https://github.com/InkProject/ink).

## Installation

### Quick install

- download tarball from http://www.chole.io/, extract and put the binary in your `PATH`
- clone this project, ssh is preferred, i.e. `git clone git@github.com:dyweb/blog.git`

### The Gopher way

tl;dr `go get -u github.com/InkProject/ink`

- [install golang](https://golang.org/doc/install)
- [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) (NOTE: install GitHub client != install git)
- config your `GOPATH` and workspace properly, remember to add `$GOPATH/bin` to your `PATH`
- install `ink` using `go get -u github.com/InkProject/ink`, this operation require `git` and `go` to be proper installed
- clone this project, ssh is preferred, i.e. `git clone git@github.com:dyweb/blog.git`

## Workflow

see [contribute guideline](.github/CONTRIBUTING.md) for detail

- preview `ink preview`
- create new post `./scripts/create-post "Cyclone" -l zh-cn -a "gaocegege"`
- before deploy `./scripts/pre-deploy`
