# Blog

This is [Dongyue Studio](http://www.dongyueweb.com)'s [team blog](http://blog.dongyueweb.com/).
Built using [ink](https://github.com/InkProject/ink).

## Installation

### Quick install

- download tarball from https://imeoer.github.io/, extract and put the binary in your `PATH`
- clone this project, ssh is preferred, i.e. `git clone git@github.com:dyweb/blog.git`

### The Gopher way

You can no longer `go get` or `go install` thanks to go mod and the replace in ink's go mod, [go#44840](https://github.com/golang/go/issues/44840)

```bash
# With go mod, you no longer need to clone the porject under right go path
git clone git@github.com:InkProject/ink.git
cd ink && go install .
```

## Workflow

see [contribute guideline](.github/CONTRIBUTING.md) for detail

- preview `ink preview`
- create new post `./scripts/create-post "Cyclone" -l zh-cn -a "gaocegege"`
- before deploy `./scripts/pre-deploy`
