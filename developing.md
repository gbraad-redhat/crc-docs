# Developing CRC

  
## Overview

The following sections describe how to build and test the project.

## Prerequisites

-   Git 
-   Make
-   A recent Go distribution (>=1.11)
    

Note: You should be able to develop the project on Linux, Windows, or macOS.


## Setting up the development environment

### Cloning the repository

Get the sources from GitHub:

```
$ git clone https://github.com/crc-org/crc.git
```

Note: Do not keep the source code in your `$GOPATH`, as [Go modules](https://github.com/golang/go/wiki/Modules) will cause `make` to fail.


## Dependency management

CRC uses [Go modules](https://github.com/golang/go/wiki/Modules) for dependency management.

For more information, see the following:

1.  [Introduction to Go modules](https://github.com/golang/go/wiki/Modules)
2.  [Using Go modules](https://blog.golang.org/using-go-modules)
    

## Compiling the CRC Binary

In order to compile the crc executable for your local platform, run the following command:

```
$ make
```

By default, the above command will place the crc executable in the `$GOBIN` path.

Run the following command to cross-compile the crc executable for many platforms:

```
$ make cross
```

**Note**: This command will output the cross-compiled crc executable(s) in the `out` directory by default:

```
$ tree out/
out/
├── linux-amd64
│&nbsp;&nbsp; └── crc
├── macos-amd64
│&nbsp;&nbsp; └── crc
└── windows-amd64
    └── crc.exe
```


## Running unit tests

To run all unit test use:

```shell
$ make test
```

If you need to update mocks use:

```shell
$ make generate_mocks
```


## Running e2e tests

We have automated e2e tests which keep CRC in shape.

### Introduction

End-to-end (e2e) tests borrow code from [Clicumber](http://github.com/crc-org/clicumber) package to provide basic functionality for testing CLI binaries. This facilitates running commands in a persistent shell instance (`bash`, `tcsh`, `zsh`, Command Prompt, or PowerShell), assert its outputs (standard output, standard error, or exit code), check configuration files, and so on. The general functionality of Clicumber is then extended by CRC specific test code to cover the whole functionality of CRC.

### How to run

First, one needs to set the following flags in `Makefile`, under `e2e` target:

-   `--pull-secret-file`: absolute path to your OpenShift pull secret.    
-   `--bundle-location`: if bundle is embedded, this flag should be set to `--bundle-location=embedded` or not passed at all; if bundle is not embedded, then absolute path to the bundle should be passed.
-   `--crc-binary`: if `crc` binary resides in `$GOPATH/bin`, then this flag needs not be passed; otherwise absolute path to the `crc` binary should be passed.

To start e2e tests, run:

```shell
$ make e2e
```

#### How to run only a subset of all e2e tests


Implicitly, all e2e tests for your operating system are executed. If you want to run only tests from one feature file, you have to override `GODOG_OPTS` environment variable. For example:

```shell
make e2e GODOG_OPTS="--godog.tags='@basic && @windows'" BUNDLE_LOCATION=<bundle location> PULL_SECRET_FILE=<pull secret path>
```

Please notice `@basic && @windows`, where `@basic` tag stands for `basic.feature` file and `@windows` tag for e2e tests designed for Windows.

### How to test cert rotation

On linux platform first stop the network time sync using:

```
$ sudo timedatectl set-ntp off
```

Set the time 2 month ahead:

```
$ sudo date -s '2 month'
```

Start the crc with `CRC_DEBUG_ENABLE_STOP_NTP=true` set:

```
$ CRC_DEBUG_ENABLE_STOP_NTP=true crc start
```

### Logs

Test logs can be found in `test/e2e/out/test-results`.


## Releasing on Github

### Releasing using the github actions workflow

The github actions workflow [`Publish release on github`](https://github.com/crc-org/crc/actions/workflows/release.yml) creates a draft release and provides a template with all the component versions and the git change log.

To start the workflow go to the [workflow page](https://github.com/crc-org/crc/actions/workflows/release.yml) and click on the `Run Workflow` button, make sure to choose the appropriate tag for the release.

Once the draft release is available, edit it to include the notable changes for the release and press publish to make it public.


### Releasing using the `gh-release.sh` script

In the CRC repository, we have a script [`gh-release.sh`](https://github.com/crc-org/crc/blob/main/gh-release.sh) which uses the [`gh`](https://cli.github.com) tool, make sure it is installed.

Create a markdown file containing a list of the notable changes named `notable_changes.txt` in the same directory as the script.

An example `notable_changes.txt`:

```shell
$ cat notable_changes.txt
- Fixes a bug where `oc` binary was not extracted from bundle when using microshift preset [#3581](https://github.com/crc-org/crc/issues/3581)
- Adds 'microshift' as a possible value to the help string of the 'preset' confg option [#3576](https://github.com/crc-org/crc/issues/3576)
```

Then run the script from the release tag and follow the prompts, it’ll ask for confirmation before pushing the draft release to github.

Note: The script will exit with error if it doesn’t find a tag starting with `v` in the current git HEAD.

```shell
$ git checkout v2.18.0
$ ./gh-release.sh
```

Verify the draft release on the releases page and if everything looks good press publish to make the release public.
