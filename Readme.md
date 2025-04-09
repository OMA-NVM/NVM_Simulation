# NVM Simulation
This repository enables to set up a toolchain containing gem5, NVMain2.0, Unikraft and various benchmark apps to simulate and evaluate non-volatile memories.

## Setup the repository
After cloning the repository, please make sure to execute the following in it:
```
git submodule init
git submodule update
```
This will ensure all required submodules are present and updated.

## Setup with VS Code and Docker development container
1.) Get [VS CODE](https://code.visualstudio.com/) and the necessary [extensions](https://code.visualstudio.com/docs/remote/remote-overview) for remote container development. Also make sure Docker is installed on your system and that docker commands can be executed by non-root users. We recommend installing docker via [their repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) and also following their [post-installation guide](https://docs.docker.com/engine/install/linux-postinstall/).

![alt text](img/extension.gif)

2.) This repository supports VS code development containers. Just open the repository folder and VS code should prompt you an information that you can reopen the folder in a docker container instead. Agree and continue with [initializing](#using-the-benchmarks). Alterantivley, click the blue "Remote Window" icon in the bottom left of VS code and select "Reopen folder in container".

![alt text](img/open.gif)

## Using the toolchain
First, the toolchain needs to be built. This includes the combination of gem5 and NVMain2.0 as well as the benchmarks - in case you want to use these. The ExampleBuild.sh script provides you with some examples for this. The toolchain is highly configureable, so please go ahead and modify these examples as needed. For more information on gem5's building, please refer to [their original website](https://www.gem5.org/).

Afterward, the simulation with gem5 and NVMain2.0 can be started. Examples for the respective commands can be found in the ExmapleBuild.sh. When using the example script, make sure that you are in the directory the example script is in. Furthermore, when using the example script, the results of the simulation will be put to the results/APPNAME.d directory. The simulation starts detached from the terminal. The gem5 output is located in results/APPNAME.d/gem5.terminal. The unikraft terminal output is located at results/APPNAME.d/m5out/system.terminal

### Enable / Disable features
We've extended the toolchain with some functionalities that aim to assist research on disruptive memory technologies. You can select them as needed. E.g., in the example script, change
```
python3 `which scons` -j 8 EXTRAS=../nvmain ./build/ARM/gem5.fast
```
e.g. to
```
python3 `which scons` CDNCcim=1 -j 8 EXTRAS=../nvmain ./build/ARM/gem5.fast
```
to enable compute-in-memory functionality. The ExampleBuild.sh currently enables the feature for bit flip simulation, targeting wear-out analysis.

Currently the following features are supported:  
bitflip: Bit-Flip Trace Writer  
CDNCcim: Compute in Memory module for NVM technologies
hybrid_cache: Heterogeneous cache extension

### TL;DR:
#### Setup
Execute only once after cloning the repository:
```
git submodule init
git submodule update
```

#### Usage
(Using ExampleBuild.sh, within the same directory)

Compile the toolchain:
```
./ExampleBuild.sh fb
```

Compile a benchmark:
```
./ExampleBuild.sh ba APPNAME
```

Simulate a benchmark:
```
./ExampleBuild.sh fe APPNAME
```

Results can be found in: results/APPNAME.d/