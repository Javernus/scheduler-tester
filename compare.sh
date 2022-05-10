#!/usr/local/bin/bash

# Compare varying IO workloads and see if it affects the CPU utilization.

mkdir ./Outputs
mkdir ./Outputs/IO_Diff
mkdir ./Outputs/MEM_Diff
mkdir ./Outputs/Diff
rm -f ./Outputs/IO_Diff/*
rm -f ./Outputs/MEM_Diff/*

CompID=3
Suffix=RRV1
IO_Constant=0

# Read Outputs/CPU_Data.txt
while read -r line;do IFS= cpu_data+=(${line}); done < "./Outputs/CPU_Data${Suffix}.txt"

# Read Outputs/MEM_Data.txt
while read -r line;do IFS= mem_data+=(${line}); done < "./Outputs/MEM_Data${Suffix}.txt"

# Works only if IO is run for all.
if [ ${IO_Constant} -eq 0 ]; then
  # Make arrays for all CPU/MEM combinations.
  for i in {0..8} ; do
    for k in {0..8} ; do
      for j in {0..8} ; do
        echo ${cpu_data[81 * ${i} + 9 * ${j} + ${k}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/IO_Diff/cpu_array${k}${i}.txt
      done
    done
  done

  # Compare the CPU utilization at each IO workload.
  for i in {0..8} ; do
    for k in {0..8} ; do
      max=$(datamash -s max 1 < ./Outputs/IO_Diff/cpu_array${k}${i}.txt)
      min=$(datamash -s min 1 < ./Outputs/IO_Diff/cpu_array${k}${i}.txt)
      diff=$(echo "$max - $min" | bc)
      ip=$(echo "$i + 1" | bc)
      kp=$(echo "$k + 1" | bc)
      echo C0.${ip}, M0.${kp}: ${diff} >> "./Outputs/Diff/CPU_IO_Diff-${CompID}.txt"
    done
  done

  # Make arrays for all CPU/MEM combinations.
  for i in {0..8} ; do
    for k in {0..8} ; do
      for j in {0..8} ; do
        echo ${mem_data[81 * ${i} + 9 * ${j} + ${k}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/IO_Diff/mem_array${k}${i}.txt
      done
    done
  done

  # Compare the MEM utilization at each IO workload.
  for i in {0..8} ; do
    for k in {0..8} ; do
      max=$(datamash -s max 1 < ./Outputs/IO_Diff/mem_array${k}${i}.txt)
      min=$(datamash -s min 1 < ./Outputs/IO_Diff/mem_array${k}${i}.txt)
      diff=$(echo "$max - $min" | bc)
      ip=$(echo "$i + 1" | bc)
      kp=$(echo "$k + 1" | bc)
      echo C0.${kp}, M0.${ip}: ${diff} >> "./Outputs/Diff/MEM_IO_Diff-${CompID}.txt"
    done
  done

  # Make arrays for all CPU workloads per MEM workload.
  for i in {0..8} ; do
    for k in {0..8} ; do
      echo ${cpu_data[81 * ${i} + 36 + ${k}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/MEM_Diff/cpu_array${k}.txt
    done
  done
else # IO is a constant.
  # Make arrays for all CPU workloads per MEM workload.
  for i in {0..8} ; do
    for j in {0..8} ; do
      echo ${cpu_data[9 * ${i} + ${j}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/MEM_Diff/cpu_array${j}.txt
    done
  done
fi

# Compare the CPU utilization at each MEM workload.
for i in {0..8} ; do
  max=$(datamash -s max 1 < ./Outputs/MEM_Diff/cpu_array${i}.txt)
  min=$(datamash -s min 1 < ./Outputs/MEM_Diff/cpu_array${i}.txt)
  diff=$(echo "$max - $min" | bc)
  ip=$(echo "$i + 1" | bc)
  echo C0.${ip}: ${diff} >> "./Outputs/Diff/CPU_MEM_Diff-${CompID}.txt"
done

# Create a CPU-MEM matrix.
for i in {0..8} ; do
  max=$(datamash -s max 1 < ./Outputs/MEM_Diff/cpu_array${i}.txt)
  min=$(datamash -s min 1 < ./Outputs/MEM_Diff/cpu_array${i}.txt)
  diff=$(echo "$max - $min" | bc)
  ip=$(echo "$i + 1" | bc)

  while read file; do
    printf '%.6f ' $file >> "./Outputs/Diff/CPU-MEM-Matrix-${CompID}.txt"
  done < ./Outputs/MEM_Diff/cpu_array${i}.txt
  printf '\n' >> "./Outputs/Diff/CPU-MEM-Matrix-${CompID}.txt"
done
