#!/usr/local/bin/bash

# Compare varying IO workloads and see if it affects the CPU utilization.

mkdir ./Outputs
mkdir ./Outputs/IO_Diff
mkdir ./Outputs/CPU_Diff
mkdir ./Outputs/MEM_Diff
mkdir ./Outputs/Diff
mkdir ./Outputs/Graph_Data
mkdir ./Outputs/Matrices
rm -f ./Outputs/IO_Diff/*
rm -f ./Outputs/CPU_Diff/*
rm -f ./Outputs/MEM_Diff/*
rm -f ./Outputs/Graph_Data/*

CompID=ThisIsSuffixForFinalFiles
Suffix=AddSuffixHere
IO_Constant=1

# Read Outputs/CPU_Data.txt
while read -r line;do IFS= cpu_data+=(${line}); done < "./Outputs/CPU_Data-${Suffix}.txt"

# Read Outputs/MEM_Data.txt
while read -r line;do IFS= mem_data+=(${line}); done < "./Outputs/MEM_Data-${Suffix}.txt"

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

  # Make arrays for all CPU workloads per CPU-MEM workload.
  for i in {0..8} ; do
    for k in {0..8} ; do
      echo ${cpu_data[81 * ${i} + 36 + ${k}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/CPU_Diff/cpu_array${k}.txt
    done
  done

  # Make arrays for all MEM workloads per CPU-MEM workload.
  for i in {0..8} ; do
    for k in {0..8} ; do
      echo ${mem_data[81 * ${i} + 36 + ${k}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/MEM_Diff/mem_array${k}.txt
    done
  done
else # IO is a constant.
  # Make arrays for all CPU workloads per CPU-MEM workload.
  for i in {0..8} ; do
    for j in {0..8} ; do
      echo ${cpu_data[9 * ${i} + ${j}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/CPU_Diff/cpu_array${j}.txt
    done
  done

  # Make arrays for all CPU workloads per CPU-MEM workload.
  for i in {0..8} ; do
    for j in {0..8} ; do
      echo ${mem_data[9 * ${i} + ${j}]} | grep -Eo "0\.[0-9]*?$" >> ./Outputs/MEM_Diff/mem_array${j}.txt
    done
  done

  # Make arrays for all CPU/MEM combinations from Graph data.
  files=( waitmem-mean waitmem-spread waitmem-min waitmem-max waitcpu-mean waitcpu-spread waitcpu-min waitcpu-max execmem-mean execmem-spread execmem-min execmem-max exectime-mean exectime-spread exectime-min exectime-max )
  for file in ${files[@]}; do
    data=()
    while read -r line;do IFS= data+=(${line}); done < "./Outputs/GData/${file}-${Suffix}.txt"
    for i in {0..8} ; do
      for j in {0..8} ; do
        echo ${data[9 * ${i} + ${j}]} | grep -Eo "\d*\.{0,1}\d*$" >> ./Outputs/GData/${file}_array${j}.txt
      done
    done
  done
fi

# Compare the CPU utilization at each MEM workload.
for i in {0..8} ; do
  max=$(datamash -s max 1 < ./Outputs/CPU_Diff/cpu_array${i}.txt)
  min=$(datamash -s min 1 < ./Outputs/CPU_Diff/cpu_array${i}.txt)
  diff=$(echo "$max - $min" | bc)
  ip=$(echo "$i + 1" | bc)
  echo C0.${ip}: ${diff} >> "./Outputs/Diff/CPU_MEM_Diff-${CompID}.txt"
done

# Create a CPU-MEM CPU-Util matrix.
for i in {0..8} ; do
  max=$(datamash -s max 1 < ./Outputs/CPU_Diff/cpu_array${i}.txt)
  min=$(datamash -s min 1 < ./Outputs/CPU_Diff/cpu_array${i}.txt)
  diff=$(echo "$max - $min" | bc)
  ip=$(echo "$i + 1" | bc)

  while read file; do
    printf '%.6f ' $file >> "./Outputs/Matrices/CPU-Util-Matrix-${CompID}.txt"
  done < ./Outputs/CPU_Diff/cpu_array${i}.txt
  printf '\n' >> "./Outputs/Matrices/CPU-Util-Matrix-${CompID}.txt"
done

# Create a CPU-MEM MEM-Util matrix.
for i in {0..8} ; do
  while read file; do
    printf '%.6f ' $file >> "./Outputs/Matrices/MEM-Util-Matrix-${CompID}.txt"
  done < ./Outputs/MEM_Diff/mem_array${i}.txt
  printf '\n' >> "./Outputs/Matrices/MEM-Util-Matrix-${CompID}.txt"
done

prefices=( waitmem waitcpu execmem exectime )
for prefix in ${prefices[@]}; do
  types=( mean spread min max )
  for type in ${types[@]}; do
    # Create a CPU-MEM data type matrix.
    for i in {0..8} ; do
      while read file; do
        printf '%.6f ' $file >> "./Outputs/Matrices/${prefix}-${type}-Matrix-${CompID}.txt"
      done < ./Outputs/GData/${prefix}-${type}_array${i}.txt
      printf '\n' >> "./Outputs/Matrices/${prefix^^}-${type}-Matrix-${CompID}.txt"
    done
  done
done
