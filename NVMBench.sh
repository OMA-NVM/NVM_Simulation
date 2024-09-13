#!/bin/bash

####################################
# This script contains some basic commands to work with the simulator.
# Please adapt it to your needs, e.g. change the config file that will be
# used for NVMain2.0.
####################################

export ROOT_DIR=$(pwd)

# BUILD
## GEM5
debugBuild() {
    echo "Building Gem5 debug version."
    cd $ROOT_DIR/simulator/gem5
    # Can't be used with --with-asan when actually debugging (running) as the leak sanitizer will fail.
    # Both it and gdb require the ptrace, which can only be occupied by one.
    # But --with-asan can still be used for everything in the address sanatizers but the memory leaks.
    # Both flags --with-ubsan and --with-asan can also be used with the gem5.fast if needed.
    #python3 `which scons` architecture=x86 tu_dortmund=1 --without-tcmalloc --with-ubsan --with-asan -j 8 EXTRAS=../nvmain ./build/ARM/gem5.debug
    python3 `which scons` architecture=x86 tu_dortmund=1 --without-tcmalloc -j 8 EXTRAS=../nvmain ./build/ARM/gem5.debug
    cd $ROOT_DIR
}

fastBuild() {
    echo "Building Gem5 fast version."
    cd $ROOT_DIR/simulator/gem5
    python3 `which scons` architecture=x86 tu_dortmund=1 -j 8 EXTRAS=../nvmain ./build/ARM/gem5.fast
    cd $ROOT_DIR
}

# APPLICATION
#Config App
configApplication() {
    echo "Configuring $1"
    cd $ROOT_DIR/unikraft_setup/apps/$1
    make menuconfig
    cd $ROOT_DIR
}

#Build App
buildApplication() {
    echo "Building $1"
    cd $ROOT_DIR/unikraft_setup/apps/$1
    rm -r build
    make
    cd $ROOT_DIR
}

# EXECUTION / DEBUG 
executionPrep() {
    echo "Preparing execution of $1."
    #Create directory for simulation
    cd $ROOT_DIR/results
    rm -r $1.d
    mkdir $1.d
    cd $1.d
    #Move app binary to directory
    cp $ROOT_DIR/unikraft_setup/apps/$1/build/$1_gem5-arm64.dbg $1_gem5-arm64.dbg
    #Move trace config to directory
    cp ../../simulator/nvmain/Config/printtrace_tu_dortmund.config printtrace_tu_dortmund.config
    cd $ROOT_DIR
}

debug() {
    echo "Debugging $1."
    #Start debug
    cd $ROOT_DIR/results/$1.d/
    export M5_PATH=.
    gdb --args $ROOT_DIR/simulator/gem5/build/ARM/gem5.debug $ROOT_DIR/simulator/gem5/configs/example/fs.py \
    --mem-type=NVMainMemory \
    --bare-metal --disk-image $ROOT_DIR/simulator/fake.iso \
    --kernel=$ROOT_DIR/results/$1.d/$1_gem5-arm64.dbg \
    --nvmain-config=$ROOT_DIR/results/$1.d/printtrace_tu_dortmund.config \
    --cpu-type=DerivO3CPU --machine-type=VExpress_GEM5_V2 --caches --l2cache \
    --l1i_size='32kB' --l1d_size='8kB' --l2_size='8kB' --dtb-filename=none \
    --mem-size=4GB
    cd $ROOT_DIR
}

execute() {
    echo "Executing $1."
    #Start simulation
    cd $ROOT_DIR/results/$1.d/
    export M5_PATH=.
    nohup $ROOT_DIR/simulator/gem5/build/ARM/gem5.fast $ROOT_DIR/simulator/gem5/configs/deprecated/example/fs.py \
    --mem-type=NVMainMemory \
    --bare-metal --disk-image $ROOT_DIR/simulator/fake.iso \
    --kernel=$ROOT_DIR/results/$1.d/$1_gem5-arm64.dbg \
    --nvmain-config=$ROOT_DIR/results/$1.d/printtrace_tu_dortmund.config \
    --cpu-type=DerivO3CPU --machine-type=VExpress_GEM5_V2 --caches --l2cache \
    --l1i_size='32kB' --l1d_size='8kB' --l2_size='8kB' --dtb-filename=none \
    --mem-size=4GB > gem5.terminal &
    disown $(jobs -p)
    cd $ROOT_DIR
}

case $1 in
    # BUILD
    ## GEM5
    fastBuild | fb)
        fastBuild
    ;;

    debugBuild | db)
        debugBuild
    ;;

    ## APPLICATION
    config | c)
        configApplication $2
    ;;

    buildApplication | ba)
        buildApplication $2
    ;;

    # EXECUTION / DEBUGGING
    prepareExecution | p)
        executionPrep $2
    ;;

    debug | d)
        executionPrep $2
        debug $2
    ;;

    fullDebug | fd)
        debugBuild
        buildApplication $2
        executionPrep $2
        debug $2
    ;;

    execute | e)
        executionPrep $2
        execute $2
    ;;

    fullExecute | fe)
        fastBuild
        buildApplication $2
        executionPrep $2
        execute $2
    ;;
    
    * | help)
        if [ "$1" = "help" ]; then
          echo "Printing help screen"
        elif [ $1 ]; then
            echo "Unknown argument: $1"
        fi
        echo "HELPING SCREEN IS STILL TODO."
esac
