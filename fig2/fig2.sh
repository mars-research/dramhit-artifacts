#!/bin/bash
#
KVSTORE_BASE=/opt/kvstore
FIG2_SRC=incrementer
KVSTORE_ARTIFACTS=${HOME}/kvstore-artifacts
FIG2_DATA=${KVSTORE_ARTIFACTS}/fig2
FIG2_SMALL=${FIG2_DATA}/fig2_32mb.csv
FIG2_BIG=${FIG2_DATA}/fig2_1gb.csv
FIG2_EPS=${FIG2_DATA}/fig2.eps

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"

run_fig2() {
  sudo ${KVSTORE_BASE}/kvstore/scripts/min-setup.sh
  pushd ${KVSTORE_BASE}/${FIG2_SRC}
  mkdir -p build && cd build
  nix-shell -p cmake gnuplot gnumake --command "cmake ../ && make -j $(nproc) && ./test |& tee -a ${FIG2_SMALL}"
  nix-shell -p cmake gnuplot gnumake --command "./test big |& tee -a ${FIG2_BIG}"
  cd ..
  popd
}

plot_fig2() {
  pushd ${FIG2_DATA}
  echo "${FIG2_BIG}"
  if [[ -f ${FIG2_BIG} && -f ${FIG2_SMALL} ]]; then
    echo "Plotting with gnuplot..."
    nix-shell -p gnuplot --command "gnuplot fig2.gnu"
    if [[ $? == 0 && -f ${FIG2_EPS} ]]; then
      #echo "ps2pdf14 ${PS2PDF_FLAGS} ${FIG2_EPS} fig2.pdf"
      echo "Converting EPS -> PDF"
      nix-shell -p ghostscript --command "ps2pdf14 ${PS2PDF_FLAGS} ${FIG2_EPS} fig2.pdf"
    fi
  fi
  popd
}

run_fig2
plot_fig2
