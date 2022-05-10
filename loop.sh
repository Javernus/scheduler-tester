#!/bin/bash
# Creating the folders to store the data.
mkdir ./Outputs
mkdir ./Outputs/MEM
mkdir ./Outputs/CPU
mkdir ./Outputs/Graph

rm -f ./Outputs/MEM/*
rm -f ./Outputs/CPU/*
rm -f ./Outputs/Graph/*

# Running the scheduler for each of the workloads.
for i in {0..728} ; do
  let CPU=i%9+1
  let IO=(i/9)%9+1
  let MEM=(i/81)%9+1

  # Indicating which workload is being run in STDOUT.
  echo $i, CPU: 0.$CPU, IO: 0.$IO, MEM: 0.$MEM

  # Running the scheduler. Tweak the range to change the number of iterations.
  for j in {1..20} ; do
    # This is the command you run. Tweak it to what you are testing.
    ./skeleton -c 0.$CPU -i 0.$IO -m 0.$MEM -p 10000 -n 50 -t 4 -v 0 > Outputs/loop.txt

    # Reading the output of the scheduler and storing important data in an output file.
    while read -r line ;
    do
      if [[ $line == "Gemiddeld gebruik geheugen:"* ]] ; then
        echo $line | grep -Eo '0\.[0-9]*?$' >> Outputs/MEM/UtilDataC${CPU}_I${IO}_M${MEM}.txt
      fi
      if [[ $line == "Gebruikte CPU-tijd:"* ]] ; then
        echo $line | grep -Eo '0\.[0-9]*?$' >> Outputs/CPU/UtilDataC${CPU}_I${IO}_M${MEM}.txt
      fi
      if [[ $line == "Histogram"* ]] ; then
        echo $line >> Outputs/Graph/UtilDataC${CPU}_I${IO}_M${MEM}.txt
      fi
      if [[ $line == "Gemiddelde waarde:"* ]] ; then
        echo $line >> Outputs/Graph/UtilDataC${CPU}_I${IO}_M${MEM}.txt
      fi
      if [[ $line == "Minimum waarde:"* ]] ; then
        echo $line >> Outputs/Graph/UtilDataC${CPU}_I${IO}_M${MEM}.txt
      fi
    done < "Outputs/loop.txt"
  done

  # Read the output file and get the average utilization per setting.
  echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. Mean Util: $(datamash -s mean 1 < "Outputs/CPU/UtilDataC${CPU}_I${IO}_M${MEM}.txt") >> Outputs/CPU_Data.txt
  echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. Mean Util: $(datamash -s mean 1 < "Outputs/MEM/UtilDataC${CPU}_I${IO}_M${MEM}.txt") >> Outputs/MEM_Data.txt
done
