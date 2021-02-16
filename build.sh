#!/usr/bin/env bash

# ImageMagick
wget -c "https://download.imagemagick.org/ImageMagick/download/binaries/magick"
chmod +x magick

# Estrutura o pacote
mkdir -p {pacote/DEBIAN,pacote/usr/tigertools,pacote/usr/share/applications}

# Lançador
cp src/launcher "pacote/usr/share/applications/AppImage-Installer.desktop"

# AppImage do ImageMagick
./magick --appimage-extract
cp -rf squashfs-root/* pacote/usr/tigertools
rm -rf squashfs-root/

# Arquivos de controle
cp "DEBIAN"/* pacote/DEBIAN

# Fontes
cp src/* "pacote/usr/tigertools/"

# Executaveis
chmod +x pacote/usr/tigertools/AppImage-Installer.sh

# Renomeia arquivos
mv "pacote/DEBIAN/control.yaml" "pacote/DEBIAN/control"
mv "pacote/usr/tigertools/AppImage-Installer.sh" "pacote/usr/tigertools/AppImage-Installer"
mv "pacote/usr/tigertools/AppRun" "pacote/usr/tigertools/convert-im6.q16"

# Remove arquivos desnecessários
rm -rf pacote/usr/tigertools/usr/etc
rm -rf pacote/usr/tigertools/usr/include
rm -rf pacote/usr/tigertools/usr/share
rm -rf pacote/usr/tigertools/usr/lib/*.a
rm -rf pacote/usr/tigertools/usr/lib/ImageMagick-7.0.10
rm -rf pacote/usr/tigertools/usr/lib/pkgconfig
rm -rf pacote/usr/tigertools/usr/lib/libdjvulibre.so*
rm -rf pacote/usr/tigertools/usr/lib/libMagick++*

# Constroi o pacote:
name=$(grep "Package:"      pacote/DEBIAN/control | cut -d' ' -f2)
vers=$(grep "Version:"      pacote/DEBIAN/control | cut -d' ' -f2)
arch=$(grep "Architecture:" pacote/DEBIAN/control | cut -d' ' -f2)
dpkg -b pacote ${name}_${vers}_${arch}.deb
