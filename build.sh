#!/bin/bash

GITHUB_BASE="https://github.com"

GITHUB_PACKS="
mdempsky/gocode
uudashr/gopkgs
ramya-rao-a/go-outline
acroca/go-symbols
cweill/gotests
fatih/gomodifytags
josharian/impl
davidrjenni/reftools
haya14busa/goplay
godoctor/godoctor
go-delve/delve
stamblerre/gocode
rogpeppe/godef
sqs/goreturns
golang/lint
golang/tools
karrick/godirwalk
pkg/errors
skratchdot/open-golang
"

GOLANG_TOOL="
github.com/mdempsky/gocode
github.com/uudashr/gopkgs/cmd/gopkgs
github.com/ramya-rao-a/go-outline
github.com/acroca/go-symbols
github.com/cweill/gotests
github.com/fatih/gomodifytags
github.com/josharian/impl
github.com/davidrjenni/reftools/cmd/fillstruct
github.com/haya14busa/goplay/cmd/goplay
github.com/godoctor/godoctor
github.com/go-delve/delve/cmd/dlv
github.com/stamblerre/gocode
github.com/rogpeppe/godef
github.com/sqs/goreturns
golang.org/x/lint
golang.org/x/tools/cmd/guru
golang.org/x/tools/cmd/gorename
"

function git_clone()
{
    CUR_PWD=`pwd`
    REPO_DIR=${1%%/*}
    if [ ! -d $REPO_DIR ];then
        mkdir $REPO_DIR
    fi
    cd $REPO_DIR
    REPO_URL=$GITHUB_BASE/$1.git
    PROJ_DIR=${1##*/}
    if [ ! -d $PROJ_DIR/.git ];then
        git clone $REPO_URL
    else
        echo "git clone $REPO_URL existed"
    fi
    
    cd $CUR_PWD
}


function go_install()
{
    GO_CMD=${1##*/}
    if [ ! -f bin/$GO_CMD.exe ];then
         go install $1
    else
        echo "$GO_CMD installed"
    fi    
}

function git_clone_foreach()
{
    for i in $GITHUB_PACKS
    do
        git_clone $i
    done
}

function go_install_foreach()
{
    for i in $GOLANG_TOOL
    do
        go_install $i
    done
}

function check_cmd()
{
    eval "$1 1>/dev/null 2>&1"
    if [ $? -eq 127 ];then
        echo $1 command not found
        exit -1
    fi
}

check_cmd "go"
check_cmd "git"

if [ "X"$GOPATH == "X" ];then
    GOPATH=`go env | grep "GOPATH" | awk -F "=" '{print $2}' | sed "s/\"//g"`
    if [ "X"$GOPATH == "X" ];then
        echo "\$GOPATH env not found"
        exit -1;
    else
        echo "\$GOPATH=$GOPATH"
    fi
fi

CUR=`pwd`

cd ${GOPATH}
mkdir src/github.com/ -p 1>&2 2>/dev/null
mkdir src/golang.org/x/ -p 1>&2 2>/dev/null
mkdir bin/ -p 1>&2 2>/dev/null

CUR_DIR=`pwd`
cd "src/github.com"
git_clone_foreach
cd $CUR_DIR

if [ ! -d "src/golang.org/x/tools" ];then
    cp -r src/github.com/tools src/golang.org/x/ 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
        echo 'cp -r src/github.com/tools src/golang.org/x/ error'
        exit -1
    fi
fi

if [ ! -d "src/golang.org/x/lint" ];then
    cp -r src/github.com/golang/lint src/golang.org/x/ 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
        echo 'cp -r src/github.com/tools src/golang.org/x/ error'
        exit -1
    fi
fi

go_install_foreach
cd $CUR