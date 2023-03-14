#!/bin/bash
#
KVSTORE_BASE=/opt/kvstore
KVSTORE_DIR=${KVSTORE_BASE}/kvstore
KVSTORE_ARTIFACTS=${HOME}/kvstore-artifacts
DATA_DIR=${KVSTORE_ARTIFACTS}/batching

BATCHING_CSV=${DATA_DIR}/batching.csv

LOG_PREFIX_DIR=esys23-ae-${USER}
CASHTPP_LARGE_DATA="${KVSTORE_DIR}/${LOG_PREFIX_DIR}/cashtpp-zipfian-large-0.01-batching/run1"
PART_LARGE_DATA="${KVSTORE_DIR}/${LOG_PREFIX_DIR}/part-zipfian-large-0.01-1:3-batching/run1"


PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"

run_ht_benchmarks() {
  pushd ${KVSTORE_DIR}
  rm -rf build
  mkdir -p build
  nix-shell --command "cd build && cmake ../ && make -j $(nproc)"
  sudo ./scripts/min-setup.sh
  nix-shell --command "./run_test.sh batching"
  popd
}

collect_csv_uniform() {
  pushd ${DATA_DIR}
  if [[ -f ${BATCHING_CSV} ]]; then rm ${BATCHING_CSV}; fi

  if [[ -d ${CASHTPP_LARGE_DATA} && -d ${PART_LARGE_DATA} ]]; then
    if [[ -f ${CASHTPP_LARGE_DATA}/cashtpp_run1.csv && -f ${PART_LARGE_DATA}/part_run1.csv ]]; then
      paste -d',' ${CASHTPP_LARGE_DATA}/cashtpp_run1.csv ${PART_LARGE_DATA}/part_run1.csv > ${BATCHING_CSV}
    fi
  fi
  popd
}

plot_figure() {
  CSV=$1
  EPS=$2.eps
  GNU=$2.gnu
  PDF=$2.pdf
  #pushd ${DATA_DIR}
  if [[ -f ${CSV} ]]; then
    echo "Plotting with gnuplot..."
    nix-shell -p gnuplot --command "gnuplot ${GNU}"
    if [[ $? == 0 && -f ${EPS} ]]; then
      echo "Converting EPS -> PDF"
      nix-shell -p ghostscript --command "ps2pdf14 ${PS2PDF_FLAGS} ${EPS} ${PDF}"
    fi
  fi
  #popd
}

# uniform HT
plot_batching() {
  plot_figure "batching.csv" "batching-set"
  plot_figure "batching.csv" "batching-get"
}

#run_ht_benchmarks
collect_csv_uniform
plot_batching
