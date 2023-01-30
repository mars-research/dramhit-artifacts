#!/bin/bash
#
KVSTORE_BASE=/opt/kvstore
KVSTORE_DIR=${KVSTORE_BASE}/kvstore
KVSTORE_ARTIFACTS=${HOME}/kvstore-artifacts
DATA_DIR=${KVSTORE_ARTIFACTS}/ht-bench
LARGE_UNIF_CSV=${DATA_DIR}/large_ht.csv
SMALL_UNIF_CSV=${DATA_DIR}/small_ht.csv

LARGE_SKEW_CSV=${DATA_DIR}/large_skewed_ht.csv
SMALL_SKEW_CSV=${DATA_DIR}/small_skewed_ht.csv

CASHT_LARGE_DATA="${KVSTORE_BASE}/kvstore/esys23-ae/casht_cashtpp-zipfian-large-0.01/run1"
PART_LARGE_DATA="${KVSTORE_BASE}/kvstore/esys23-ae/part-zipfian-large-0.01-1:3/run1"

CASHT_SMALL_DATA="${KVSTORE_BASE}/kvstore/esys23-ae/casht_cashtpp-zipfian-small-0.01/run1"
PART_SMALL_DATA="${KVSTORE_BASE}/kvstore/esys23-ae/part-zipfian-small-0.01-1:3/run1"

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"

run_ht_benchmarks() {
  pushd ${KVSTORE_DIR}
  mkdir -p build && cd build
  nix-shell --command "cmake ../ && make -j $(nproc)"
  cd ..
  nix-shell --command "./run_test.sh"
  popd
}

collect_csv_uniform() {
  pushd ${DATA_DIR}
  if [[ -f ${LARGE_UNIF_CSV} ]]; then rm ${LARGE_UNIF_CSV}; fi
  if [[ -f ${SMALL_UNIF_CSV} ]]; then rm ${SMALL_UNIF_CSV}; fi

  if [[ -d ${CASHT_LARGE_DATA} && -d ${PART_LARGE_DATA} && -d ${CASHT_SMALL_DATA} && -d ${PART_SMALL_DATA} ]]; then
    if [[ -f ${CASHT_LARGE_DATA}/casht_run1.csv && -f ${CASHT_LARGE_DATA}/cashtpp_run1.csv && -f ${PART_LARGE_DATA}/part_run1.csv ]]; then
      paste -d',' ${CASHT_LARGE_DATA}/casht_run1.csv ${CASHT_LARGE_DATA}/cashtpp_run1.csv ${PART_LARGE_DATA}/part_run1.csv > ${LARGE_UNIF_CSV}
    fi
    if [[ -f ${CASHT_SMALL_DATA}/casht_run1.csv && -f ${CASHT_SMALL_DATA}/cashtpp_run1.csv && -f ${PART_SMALL_DATA}/part_run1.csv ]]; then
      paste -d',' ${CASHT_SMALL_DATA}/casht_run1.csv ${CASHT_SMALL_DATA}/cashtpp_run1.csv ${PART_SMALL_DATA}/part_run1.csv > ${SMALL_UNIF_CSV}
    fi
  fi
  popd
}

collect_csv_skewed() {
  if [[ -f ${LARGE_SKEW_CSV} ]]; then rm ${LARGE_SKEW_CSV}; fi
  if [[ -f ${SMALL_SKEW_CSV} ]]; then rm ${SMALL_SKEW_CSV}; fi
  CASHT_SKEW_SMALL="${KVSTORE_BASE}/kvstore/esys23-ae/casht_cashtpp-zipfian-small-\${skew}/run1"
  CASHT_SKEW_LARGE="${KVSTORE_BASE}/kvstore/esys23-ae/casht_cashtpp-zipfian-large-\${skew}/run1"
  PART_SKEW_SMALL="${KVSTORE_BASE}/kvstore/esys23-ae/part-zipfian-small-\${skew}/run1"
  PART_SKEW_LARGE="${KVSTORE_BASE}/kvstore/esys23-ae/part-zipfian-large-\${skew}/run1"

  pushd ${DATA_DIR}
  for skew in $(seq 0.2 0.2 0.6) $(seq 0.8 0.01 1.09); do
    CASHT_SMALL=$(eval "echo ${CASHT_SKEW_SMALL}")
    CASHT_LARGE=$(eval "echo ${CASHT_SKEW_LARGE}")
    PART_SMALL=$(eval "echo ${PART_SKEW_SMALL}")
    PART_LARGE=$(eval "echo ${PART_SKEW_LARGE}")

    if [ ${skew} == "0.2" ]; then
      NUM=2;
    else
      NUM=1;
    fi

    SKEW_TMP=$(mktemp /tmp/skew_XXX)
    echo -e "skew\n${skew}" > ${SKEW_TMP}

    if [[ -d ${CASHT_SMALL} && -d ${CASHT_LARGE} && -d ${PART_SMALL} && -d ${PART_LARGE} ]]; then
      if [[ -f ${CASHT_LARGE}/casht_run1.csv && -f ${CASHT_LARGE}/cashtpp_run1.csv && -f ${PART_LARGE}/part_run1.csv ]]; then
        paste -d',' ${SKEW_TMP} ${CASHT_LARGE}/casht_run1.csv ${CASHT_LARGE}/cashtpp_run1.csv ${PART_LARGE}/part_run1.csv | tail -${NUM} >> ${LARGE_SKEW_CSV}
      fi
      if [[ -f ${CASHT_SMALL}/casht_run1.csv && -f ${CASHT_SMALL}/cashtpp_run1.csv && -f ${PART_SMALL}/part_run1.csv ]]; then
        paste -d',' ${SKEW_TMP} ${CASHT_SMALL}/casht_run1.csv ${CASHT_SMALL}/cashtpp_run1.csv ${PART_SMALL}/part_run1.csv | tail -${NUM} >> ${SMALL_SKEW_CSV}
      fi
    fi
  done
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
plot_uniform() {
  plot_figure "small_ht.csv" "fig7"
  plot_figure "large_ht.csv" "fig8"
  plot_figure "small_ht.csv" "fig9"
  plot_figure "large_ht.csv" "fig10"
}

# Skewed HT
plot_skewed() {
  plot_figure "small_skewed_ht.csv" "fig11"
  plot_figure "small_skewed_ht.csv" "fig12"
  plot_figure "large_skewed_ht.csv" "fig13"
  plot_figure "large_skewed_ht.csv" "fig14"
}

run_ht_benchmarks
collect_csv_uniform
collect_csv_skewed
plot_uniform
plot_skewed
