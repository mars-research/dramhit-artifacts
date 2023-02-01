#!/bin/bash
#
KVSTORE_BASE=/opt/kvstore
KVSTORE_DIR=${KVSTORE_BASE}/kvstore
CHTKC_DIR=${KVSTORE_BASE}/chtkc

KVSTORE_ARTIFACTS=${HOME}/kvstore-artifacts
DATA_DIR=${KVSTORE_ARTIFACTS}/kmer-bench

CHTKC_CSV=${DATA_DIR}/summary_chtkc.csv
KVSTORE_CSV=${DATA_DIR}/part.csv

DATASETS=("dmela" "fvesca")

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"

run_kmer_benchmarks() {
  pushd ${KVSTORE_DIR}
  rm -rf build
  mkdir -p build
  nix-shell --command "cd build && cmake ../ && make -j $(nproc)"
  nix-shell --command "./run_test.sh kmer"
  popd
}

run_chtkc_benchmarks() {
  pushd ${CHTKC_DIR}
  rm -rf build
  mkdir -p build && cd build
  nix-shell -p cmake gnumake zlib --command "cmake ../ && make -j $(nproc)"
  cd ..
  nix-shell -p cmake gnumake zlib --command "./run_chtkc.sh"
  popd
}

collect_csv_kmer() {
  SUMMARY_DMELA_CSV="${CHTKC_DIR}/summary_${DATASETS[0]}.csv"
  SUMMARY_FVESCA_CSV="${CHTKC_DIR}/summary_${DATASETS[1]}.csv"

  if [[ -f ${SUMMARY_FVESCA_CSV} && -f ${SUMMARY_DMELA_CSV} ]]; then
    paste -d ',' ${SUMMARY_DMELA_CSV} ${SUMMARY_FVESCA_CSV} > ${CHTKC_CSV}
  fi
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

plot_kmer() {
  plot_figure "dmela.csv" "fig16"
  plot_figure "fvesca.csv" "fig17"
}

run() {
  run_kmer_benchmarks
  run_chtkc_benchmarks
}

run
collect_csv_kmer
plot_kmer
