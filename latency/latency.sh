#!/bin/bash
#
DRAMHIT_BASE=/opt/dramhit

PS2PDF_FLAGS="-dEPSCrop -dPDFSETTINGS=/printer -dColorConversionStrategy=/RGB -dProcessColorModel=/DeviceRGB -dEmbedAllFonts=true -dSubsetFonts=true -dMaxSubsetPct=100"
LATENCY_EPS="latency.eps"

run_latency() {
  python latency.py
}

plot_latency() {
  echo "Plotting with gnuplot..."
  nix-shell -p gnuplot --command "gnuplot latency.gnu"
  if [[ $? == 0 && -f ${LATENCY_EPS} ]]; then
    echo "Converting EPS -> PDF"
    nix-shell -p ghostscript --command "ps2pdf14 ${PS2PDF_FLAGS} ${LATENCY_EPS} latency.pdf"
  fi
}

run_latency
plot_latency
