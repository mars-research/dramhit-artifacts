#!/bin/bash
#
KVSTORE_BASE=/opt/kvstore

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"
FIG15_EPS="fig15.eps"

run_fig15() {
  python fig15.py
}

plot_fig15() {
  echo "Plotting with gnuplot..."
  nix-shell -p gnuplot --command "gnuplot fig15.gnu"
  if [[ $? == 0 && -f ${FIG15_EPS} ]]; then
    echo "Converting EPS -> PDF"
    nix-shell -p ghostscript --command "ps2pdf14 ${PS2PDF_FLAGS} ${FIG15_EPS} fig15.pdf"
  fi
}

run_fig15
plot_fig15
