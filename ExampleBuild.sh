#!/bin/bash

####################################
# This script bundles some commands to build and execute the toolchain.
# Currently, it targets bit-flip simulation for wear-out analysis.
#
# This script gives a broad example on what needs to be done to use the
# toolchain. Please adapt/extend everything to your linking.
#
# The current configuration is used by the commands:
# - NVMain2.0 configuration file: printtrace_bitflip.config
# - Application to simulate: Benchmark based on argument (needs to be built first).
# - System:
#   - ISA: ARM64
#   - CPU: DerivO3CPU -> Out of order CPU
#   - Platform: VExpress_GEM5_V2
#   - L1 instruction cache: 32KB
#   - L1 data cache: 8KB
#   - L2 cache: 8KB
#   - Memory: 4GB
####################################

export ROOT_DIR=$(pwd)

# BUILDING GEM5
###
# Here we give an example for build a fast version
# of gem5 and one that has debug information available.
###
debugBuild() {
    echo "Building gem5 with debug information."
    cd $ROOT_DIR/simulator/gem5
    # Can't be used with --with-asan when actually debugging (running) as the leak sanitizer will fail.
    # Both it and gdb require the ptrace, which can only be occupied by one.
    # But --with-asan can still be used for everything in the address sanatizers besides the memory leaks.
    # Both flags --with-ubsan and --with-asan can also be used with the gem5.fast if needed.
    python3 `which scons` bitflip=1 --without-tcmalloc -j 8 EXTRAS=../nvmain ./build/ARM/gem5.debug
    cd $ROOT_DIR
}

fastBuild() {
    echo "Building gem5 fast version."
    cd $ROOT_DIR/simulator/gem5
    python3 `which scons` bitflip=1 -j 8 EXTRAS=../nvmain ./build/ARM/gem5.fast
    cd $ROOT_DIR
}

# APPLICATION
# Config App
###
# Example commands to configure the provided
# benchmarks with unikraft. They should already be
# configured when this repository is cloned. Update
# their configuration if you want to.
###
configApplication() {
    echo "Configuring $1"
    cd $ROOT_DIR/unikraft_setup/apps/$1
    make menuconfig
    cd $ROOT_DIR
}

# Build App
###
# The commands to build a benchmark
# previously configured.
###
buildApplication() {
    echo "Building $1"
    cd $ROOT_DIR/unikraft_setup/apps/$1
    rm -r build
    make
    cd $ROOT_DIR
}

# EXECUTION / DEBUG
###
# Setting up the results directory and moving
# the NVMain2.0 trace configuration to the correct
# destination.
###
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
    cp ../../simulator/nvmain/Config/printtrace_bitflip.config printtrace_bitflip.config
    cd $ROOT_DIR
}

###
# Simulating the given benchmark with
# the debug version of gem5 using the
# described system.
###
debug() {
    echo "Debugging $1."
    #Start debug
    cd $ROOT_DIR/results/$1.d/
    export M5_PATH=.
    gdb --args $ROOT_DIR/simulator/gem5/build/ARM/gem5.debug $ROOT_DIR/simulator/gem5/configs/example/fs.py \
    --mem-type=NVMainMemory \
    --bare-metal --disk-image $ROOT_DIR/simulator/fake.iso \
    --kernel=$ROOT_DIR/results/$1.d/$1_gem5-arm64.dbg \
    --nvmain-config=$ROOT_DIR/results/$1.d/printtrace_bitflip.config \
    --cpu-type=DerivO3CPU --machine-type=VExpress_GEM5_V2 --caches --l2cache \
    --l1i_size='32kB' --l1d_size='8kB' --l2_size='8kB' --dtb-filename=none \
    --mem-size=4GB
    cd $ROOT_DIR
}

###
# Simulating the given benchmark with
# the fast version of gem5 using the
# described system.
###
execute() {
    echo "Executing $1."
    #Start simulation
    cd $ROOT_DIR/results/$1.d/
    export M5_PATH=.
    nohup $ROOT_DIR/simulator/gem5/build/ARM/gem5.fast $ROOT_DIR/simulator/gem5/configs/deprecated/example/fs.py \
    --mem-type=NVMainMemory \
    --bare-metal --disk-image $ROOT_DIR/simulator/fake.iso \
    --kernel=$ROOT_DIR/results/$1.d/$1_gem5-arm64.dbg \
    --nvmain-config=$ROOT_DIR/results/$1.d/printtrace_bitflip.config \
    --cpu-type=DerivO3CPU --machine-type=VExpress_GEM5_V2 --caches --l2cache \
    --l1i_size='32kB' --l1d_size='8kB' --l2_size='8kB' --dtb-filename=none \
    --mem-size=4GB > gem5.terminal &
    disown $(jobs -p)
    cd $ROOT_DIR
}

###
# Terminal interface
###
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
