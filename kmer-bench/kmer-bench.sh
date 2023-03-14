#!/bin/bash
#
DRAMHIT_BASE=/opt/dramhit
DRAMHIT_DIR=${DRAMHIT_BASE}/dramhit
CHTKC_DIR=${DRAMHIT_BASE}/chtkc

DRAMHIT_ARTIFACTS=${HOME}/dramhit-artifacts
DATA_DIR=${DRAMHIT_ARTIFACTS}/kmer-bench

CHTKC_CSV=${DATA_DIR}/summary_chtkc.csv
DRAMHIT_CSV=${DATA_DIR}/summary_dramhit.csv

DATASETS=("dmela" "fvesca")

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"

run_kmer_benchmarks() {
  pushd ${DRAMHIT_DIR}
  rm -rf build
  mkdir -p build
  nix-shell --command "cd build && cmake -DAGGR=ON -DBQ_KMER_TEST=ON ../ && make -j $(nproc)"
  sudo ./scripts/min-setup.sh
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
  CHTKC_LOG_PREFIX="esys23-ae-${USER}/run"
  SUMMARY_DMELA_CSV="${CHTKC_DIR}/${CHTKC_LOG_PREFIX}/summary_${DATASETS[0]}.csv"
  SUMMARY_FVESCA_CSV="${CHTKC_DIR}/${CHTKC_LOG_PREFIX}/summary_${DATASETS[1]}.csv"

  if [[ -f ${SUMMARY_FVESCA_CSV} && -f ${SUMMARY_DMELA_CSV} ]]; then
    paste -d ',' ${SUMMARY_DMELA_CSV} ${SUMMARY_FVESCA_CSV} > ${CHTKC_CSV}
  fi

  CASHT_CSV="${DRAMHIT_BASE}/dramhit/esys23-ae-${USER}/casht-kmer-\${genome}/run1/summary_\${genome}.csv"
  CASHTPP_CSV="${DRAMHIT_BASE}/dramhit/esys23-ae-${USER}/cashtpp-kmer-\${genome}/run1/summary_\${genome}.csv"
  PART_CSV="${DRAMHIT_BASE}/dramhit/esys23-ae-${USER}/part-kmer-\${genome}/run1/summary_\${genome}.csv"

  for genome in ${DATASETS[@]}; do
    CASHT_GENOME_CSV=$(eval "echo ${CASHT_CSV}")
    CASHTPP_GENOME_CSV=$(eval "echo ${CASHTPP_CSV}")
    PART_GENOME_CSV=$(eval "echo ${PART_CSV}")

    if [[ -f ${CASHT_GENOME_CSV} && -f ${CASHTPP_GENOME_CSV} && ${PART_GENOME_CSV} ]]; then
      paste -d',' ${CASHT_GENOME_CSV} ${CASHTPP_GENOME_CSV} ${PART_GENOME_CSV} > ${DRAMHIT_CSV}.${genome}
    fi
  done

  paste -d',' ${DRAMHIT_CSV}."dmela" ${DRAMHIT_CSV}."fvesca" > ${DRAMHIT_CSV}

  if [[ -f ${CHTKC_CSV} && -f ${DRAMHIT_CSV} ]];then
    paste -d',' ${CHTKC_CSV} ${DRAMHIT_CSV} > summary_kmer.csv
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
  plot_figure "summary_kmer.csv" "fig16"
  plot_figure "summary_kmer.csv" "fig17"
}

run() {
  run_kmer_benchmarks
  run_chtkc_benchmarks
}

run
collect_csv_kmer
plot_kmer
