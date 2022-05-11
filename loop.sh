#!/bin/bash
# Creating the folders to store the data.
mkdir ./Outputs
mkdir ./Outputs/MEM/
mkdir ./Outputs/CPU/
mkdir ./Outputs/Graph/
mkdir ./Outputs/GData/

rm -f ./Outputs/MEM/*
rm -f ./Outputs/CPU/*
rm -f ./Outputs/Graph/*
rm -f ./Outputs/GData/*

Suffix=AdvN50T3V5

# Running the scheduler for each of the workloads.
for MEM in {1..9} ; do
  # Testing showed that IO made an unremarkable difference on the CPU utilization.
  # So we will only run the scheduler for IO workload 0.5.
  for IO in {5..5} ; do
    for CPU in {1..9} ; do
      # Indicating which workload is being run in STDOUT.
      echo Running CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}

      # Running the scheduler. Tweak the range to change the number of iterations.
      for j in {1..15} ; do
        # This is the command you run. Tweak it to what you are testing.
        ./skeleton -c 0.${CPU} -i 0.${IO} -m 0.${MEM} -p 10000 -n 50 -t 3 -v 2 > Outputs/loop.txt

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

echo Processing Graph data now...
for MEM in {1..9} ; do
  for IO in {5..5} ; do
    for CPU in {1..9} ; do
      type="waitmem"
      while read -r line ; do
        if [[ $line == *"wachttijd op geheugentoewijzing" ]] ; then
          type="waitmem"
        elif [[ $line == *"wachttijd op eerste CPU cycle" ]] ; then
          type="waitcpu"
        elif [[ $line == *"executie-tijd vanaf geheugentoewijzing" ]] ; then
          type="execmem"
        elif [[ $line == *"totale verwerkingstijd" ]] ; then
          type="exectime"
        elif [[ $line == "Gemiddelde waarde"* ]] ; then
          echo $line | grep -Eo 'Gemiddelde waarde: \d*\.{0,1}\d*' | grep -Eo '\d*\.{0,1}\d*$' >> Outputs/Graph/${type}-mean-C${CPU}_I${IO}_M${MEM}.txt
          echo $line | grep -Eo '\d*\.{0,1}\d*$' >> Outputs/Graph/${type}-spread-C${CPU}_I${IO}_M${MEM}.txt
        elif [[ $line == "Minimum waarde"* ]] ; then
          echo $line | grep -Eo 'Minimum waarde: \d*\.{0,1}\d*' | grep -Eo '\d*\.{0,1}\d*$' >> Outputs/Graph/${type}-minimum-C${CPU}_I${IO}_M${MEM}.txt
          echo $line | grep -Eo '\d*\.{0,1}\d*$' >> Outputs/Graph/${type}-maximum-C${CPU}_I${IO}_M${MEM}.txt
        fi
      done < "Outputs/Graph/UtilDataC${CPU}_I${IO}_M${MEM}.txt"

      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitmem-mean-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITMEM-mean-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitmem-spread-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITMEM-spread-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitmem-minimum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITMEM-min-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitmem-maximum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITMEM-max-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitcpu-mean-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITCPU-mean-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitcpu-spread-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITCPU-spread-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitcpu-minimum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITCPU-min-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/waitcpu-maximum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/WAITCPU-max-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/execmem-mean-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECMEM-mean-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/execmem-spread-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECMEM-spread-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/execmem-minimum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECMEM-min-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/execmem-maximum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECMEM-max-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/exectime-mean-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECTIME-mean-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/exectime-spread-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECTIME-spread-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/exectime-minimum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECTIME-min-${Suffix}.txt
      echo CPU: 0.${CPU}, IO: 0.${IO}, MEM: 0.${MEM}. $(datamash -s mean 1 < "Outputs/GData/exectime-maximum-C${CPU}_I${IO}_M${MEM}.txt") >> Outputs/GData/EXECTIME-max-${Suffix}.txt
    done
  done
done
