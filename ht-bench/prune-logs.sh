#!/bin/bash

for i in $(ls *-zipfian-*/run1/*_run1.csv); do
  SKEW=$(echo ${i} | cut -d'/' -f1 | grep -o "[^-]*$")
  HT_TYPE=$(echo ${i} | cut -d'/' -f1 | cut -d'-' -f1)
  if [[ ${HT_TYPE} == "casht_cashtpp" ]]; then
    if [[ ${SKEW} == "0.01" ]]; then
      echo "$(tail -65 ${i})" > ${i};
    else
      echo "$(tail -2 ${i})" > ${i};
    fi
  elif [[ ${HT_TYPE} == "part" ]]; then
    if [ ${SKEW} == "1:3" ]; then
      echo "$(tail -65 ${i})" > ${i};
    else
      echo "$(tail -2 ${i})" > ${i};
    fi
  fi
done
