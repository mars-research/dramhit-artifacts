#!/bin/bash
#
DRAMHIT_BASE=/opt/dramhit/dramhit

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"

run_fig() {
  pushd ${DRAMHIT_BASE}/build
  python ../scripts/pollutions.py > runs.sh
  sh -x runs.sh
  popd
}

plot_fig() {
  echo "Plotting with gnuplot..."
  nix-shell -p gnuplot --command "gnuplot $1.gnu"
  if [[ $? == 0 && -f $1.eps ]]; then
    echo "Converting EPS -> PDF"
    nix-shell -p ghostscript --command "ps2pdf14 ${PS2PDF_FLAGS} $1.eps $1.pdf"
  fi
}

run_fig
python pkg.py ${DRAMHIT_BASE}/build > pollutions.csv
plot_fig pollutions-set
plot_fig pollutions-get
