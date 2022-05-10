# scheduler-tester
Tester for the Operating Systems course Schedulers. 

## Requirements
Install `datamash`. This can be done using `brew` on MacOS:

```
brew install datamash
```

Also make sure you have a high enough version of `bash`. You can install a later version on MacOS like so:

`brew install bash`

On other OSes, make sure to update the top reference to bash (`#!/bin/bash`) to the install location.

## Usage
Run using `./loop.sh` in the terminal creates data. This takes a long time. 

Change parameters in `loop.sh` to differ in what you want to test.

Run `./compare.sh` in the terminal to compare workloads of a scheduler. 

Change `IO_Constant` if to indicate whether you are using a constant IO or are using 0.1-0.9 for IO.

You can run `python3 plots.py` to generate plots. Do not forget to change the file paths at the bottom of the file.
