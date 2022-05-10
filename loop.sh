#!/bin/bash
# Creating the folders to store the data.
mkdir ./Outputs
mkdir ./Outputs/MEM/
mkdir ./Outputs/CPU/
mkdir ./Outputs/Graph/

rm -f ./Outputs/MEM/*
rm -f ./Outputs/CPU/*
rm -f ./Outputs/Graph/*

Suffix=1

# Running the scheduler for each of the workloads.
for CPU in {1..9} ; do
  # Testing showed that IO made an unremarkable difference on the CPU utilization.
  # So we will only run the scheduler for IO workload 0.5.
  for IO in {5..5} ; do
    for MEM in {1..9} ; do
      # Indicating which workload is being run in STDOUT.
      echo $CPU + 9 * $IO + 81 * $MEM, CPU: 0.$CPU, IO: 0.$IO, MEM: 0.$MEM

      # Running the scheduler. Tweak the range to change the number of iterations.
      for j in {1..50} ; do
        # This is the command you run. Tweak it to what you are testing.
        ./skeleton -c 0.$CPU -i 0.5 -m 0.$MEM -p 10000 -n 50 -t 2 -v 2 > Outputs/loop.txt

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
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. Mean Util: $(datamash -s mean 1 < "Outputs/CPU/UtilDataC${CPU}_I${IO}_M${MEM}.txt") >> Outputs/CPU_Data-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. Mean Util: $(datamash -s mean 1 < "Outputs/MEM/UtilDataC${CPU}_I${IO}_M${MEM}.txt") >> Outputs/MEM_Data-${Suffix}.txt
    done
  done
done
