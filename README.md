# Toucan

## Docker usage
After cloning the repo, you can use docker to run the Toucan model. 

In order to modify the runtime parameters like cultivars and runtime arguments, modify the `.../Toucan/docker-scripts/run_configuration.yaml` file. This file looks like
```
model_run_args: ETH 4 0
cultivars:
  - MZCER048.CUL.990003
cultivar_directory: /codebase/Toucan/res/.csm/
``` 

Where the `model_run_args` are the commandline arguments passed to the Toucan model. The `cultivars` header starts a list of cultivars that may have any number of cultivars for the model run. Each cultivar is defined as the cultivar file name (ex. `MZCER048.CUL`) appended to the cultivar var number (ex. `990003`) by a period.

Example of a bigger cultivar list:
```
model_run_args: ETH 4 0
cultivars:
  - MZCER048.CUL.990003
  - MZCER048.CUL.990002
  - VBGRO048.CUL.CC0001
  ...
```

### First run 
```
docker build . -t toucan-container:latest
``` 
which will build the container for you.

Next run 
``` 
docker compose run toucan
```

This will place results files from the run in `.../Toucan/results` and will place error files in `.../Toucan/errors`

## 1. Compiling DSSAT
Amazon Linux 2:
```
sudo yum install gcc-gfortran
sudo yum install glibc-static
sudo yum install git
sudo yum install maven
sudo yum install cmake
mkdir codebase
cd codebase
git clone https://github.com/dssat/dssat-csm-os
cd dscsm-csm-os
mkdir release
cd release
cmake -DCMAKE_BUILD_TYPE=Release ..
make
```
Or, Ubuntu:
```
sudo apt install gfortran
sudo apt install cmake
sudo apt install maven
mkdir codebase
cd codebase
git clone https://github.com/dssat/dssat-csm-os
cd dscsm-csm-os
mkdir release
cd release
cmake -DCMAKE_BUILD_TYPE=Release ..
make
```
Now you have the DSSAT executable file ready to go.

## 2. Cloning Toucan from this repo
(Toucan is the cute name I gave to my Java program that batch-runs DSSAT)

```
cd ~/codebase
git clone https://github.com/jawoo/Toucan
cd Toucan
mvn install
mvn compile
mvn package
```

## 3. Copy DSSAT files to the resource directory
For the sake of simplicity, I keep *all* files into one directory with no subdirectories.
```
cd ~/codebase/Toucan/res
mkdir -p .csm .temp result threads
cp ~/codebase/dssat-csm-os/Data/* ./.csm
cp ~/codebase/dssat-csm-os/Data/Genotype/* ./.csm
cp ~/codebase/dssat-csm-os/Data/Pest/* ./.csm
cp ~/codebase/dssat-csm-os/Data/StandardData/* ./.csm
cp ~/codebase/dssat-csm-os/release/bin/dscsm048 ./.csm/DSCSM048.EXE
```
And, while we're at it, also create some directories to collect and process temporary files.
```
cd ~/codebase/Toucan/res/.temp
mkdir summary multipleplanting flowering planting error
```

## 4. Flag which cultivar to use in the simulation
You'll need to flag in the cultivar file (*.CUL) to tell the program which cultivar to use. Open the cultivar file for the crop you'd like to use (e.g., MZCER.048.CUL) in the res/.csm directory and add a space and an asterisk at the end of the line, like the following:

```
990002 MEDIUM SEASON        . IB0001 200.0 0.300 800.0 700.0  8.50 38.90 *
```
You can flag as many cultivars as you like.

## 5. Run Toucan

```
cd ~/codebase/Toucan/
java -cp "target/ToucanSNX-1.0-SNAPSHOT.jar:lib/*" org.cgiar.toucan.App ETH 4 0
```
The arguments used in this example are ETH (country code; Ethiopia), 4 (number of threads; keep it less than the number of CPUs) and 0 (change it to 1 for debugging).

After all the batch runs are completed, you can pick up the merged CSV output file at ~/codebase/Toucan/res/result directory. Enjoy!
