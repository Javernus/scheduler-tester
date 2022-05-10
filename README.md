# scheduler-tester
Tester for the Operating Systems course Schedulers. 

## Requirements
Install `datamash` and `mapfile`. This can be done using `brew` on MacOS:

```
brew install datamash mapfile
```

## Usage
Run using `./loop.sh` in the terminal creates data. This takes a long time. 
Change parameters in `loop.sh` to differ in what you want to test.
Run `./compare.sh` in the terminal to compare workloads of a scheduler. 
Change IO_Constant if to indicate whether you are using a constant IO or are using 0.1-0.9 for IO.
