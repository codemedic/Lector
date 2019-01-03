#! /bin/bash

sudo apt -y install git

export VERSION=$(wget -q "https://api.github.com/repos/BasioMeusPuga/Lector/commits?sha=master" -O - | grep sha | head -n 1 | cut -d '"' -f 4 | head -c 7
)

export APPNAME=lector
export PIP_REQUIREMENTS="-e git+https://github.com/BasioMeusPuga/Lector#egg=$APPNAME"
export CONDA_CHANNELS="conda-forge"
export CONDA_PACKAGES="pyqt;beautifulsoup4"  # Only use this if the package is in a Conda channel (e.g., conda-forge); can also be used for dependencies if the main application has no depends.txt
export VERSION=$(git rev-parse --short HEAD) # linuxdeployqt uses this for naming the file

wget -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
wget -c "https://raw.githubusercontent.com/TheAssassin/linuxdeploy-plugin-conda/master/linuxdeploy-plugin-conda.sh"
chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-conda.sh

rm -r AppDir || true

wget -c "https://github.com/BasioMeusPuga/Lector/raw/master/lector/resources/raw/lector.desktop"
sed -i -e 's|Icon=L|Icon=l|g' lector.desktop # FIXME

cat > AppRun <<\EOF
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
exec "$HERE/usr/conda/bin/python" "$HERE/usr/conda/bin/lector" "$@"
EOF
chmod +x AppRun

wget -c "https://raw.githubusercontent.com/BasioMeusPuga/Lector/ed5bc0b2b9b92a506d4eb2144e349075caf3a8c0/lector/resources/raw/Lector.png" -O app.png
convert app.png -resize 512x512 $APPNAME.png

./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin conda -i $APPNAME.png -d $(readlink -f "$APPNAME.desktop") --custom-apprun AppRun --output appimage
