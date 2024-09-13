#!/bin/bash

export ROOT_DIR=$(pwd)
export NVMAIN_DIR=$ROOT_DIR/simulator/nvmain

checkoutEx1() {
    cd $NVMAIN_DIR
    git stash
    git checkout TU-Dortmund-Tutorial-Ex1
    cd $ROOT_DIR
}

checkoutEx1Solution() {
    cd $NVMAIN_DIR
    git stash
    git checkout TU-Dortmund-Tutorial-Ex1-Solution
    cd $ROOT_DIR
}

checkoutEx2() {
    cd $NVMAIN_DIR
    git stash
    git checkout TU-Dortmund-Tutorial-Ex2
    cd $ROOT_DIR
}

checkoutEx2Solution() {
    cd $NVMAIN_DIR
    git stash
    git checkout TU-Dortmund-Tutorial-Ex2-Solution
    cd $ROOT_DIR
}

compile() {
    ./NVMBench.sh fb
}

run() {
    ./NVMBench e helloworld
}

case $1 in
    ex1)
        checkoutEx1
    ;;

    ex1solution)
        checkoutEx1Solution
    ;;

    ex2)
        checkoutEx2
    ;;

    ex2solution)
        checkoutEx2Solution
    ;;

    c)
        compile
    ;;

    r)
        run
    ;;
esac