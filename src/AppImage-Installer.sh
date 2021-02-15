#!/bin/bash

export HERE="$(dirname "$(readlink -f "${0}")")"
export SELF=$(readlink -f "${0}")

function getData(){
  #-----------------------------------------------------------------------------------------------------------------
  
  appimage_root=$(unsquashfs -q -o "${offset}" -l "${file_name}"| cut -c 15- | grep -v "/" | sort)
  compressed_desktop_file=$(echo -E "${appimage_root}"  | grep .desktop | head -n1)

  unsquashfs -f -q -o "${offset}" -d "${data_dir}" "${file_name}" ".DirIcon"  2>&1 > /dev/null
  icon_file=$(readlink "${data_dir}/.DirIcon")
  [ ! -z "${icon_file}" ] && {
    unsquashfs -f -q -o "${offset}" -d "${data_dir}" "${file_name}" "${icon_file}"
    icon_file="${data_dir}/${icon_file}"
  } || {
    icon_file="${data_dir}/.DirIcon"
  }
  unsquashfs -f -q -o "${offset}" -d "${data_dir}" "${file_name}" "${compressed_desktop_file}" 2>&1 > /dev/null
  desktop_file=$(readlink "${data_dir}/${compressed_desktop_file}")
  [ ! -z "${desktop_file}" ] && {
    unsquashfs -f -q -o "${offset}" -d "${data_dir}" "${file_name}" "${icon_file}"
    desktop_file="${data_dir}/${desktop_file}"
  } || {
    desktop_file="${data_dir}/${compressed_desktop_file}"
  }
  
  [ ! -f "${desktop_file}" ] && {
    echo "The ${desktop_file} AppImage is not for installing!"
    return 1
  }
  
  [ ! -f "${icon_file}" ] && {
    echo "Warning: fallbacking icon since application doesn't have one"
    icon_file="${HERE}/appimage.png"
  }
  
  file_size=$(du -k "${file_name}" | tr '[[:space:]]' ' '  | cut -d' ' -f1)
  
  #-----------------------------------------------------------------------------------------------------------------
  
  hash=$(md5sum "${file_name}" | cut -d' ' -f1)
  
  #-----------------------------------------------------------------------------------------------------------------
  
  echo "Launcher: ${desktop_file}"
  echo "Icon: ${icon_file}"
  
  appname=$(grep -A 10000 "\[Desktop Entry]" "${desktop_file}" | grep -m1 ^"Name\[$(echo ${LANG} | cut -d. -f1)]=")
  [ -z "${appname}" ] && {
    appname=$(grep -A 10000 "\[Desktop Entry]" "${desktop_file}" | grep -m1 ^"Name=")
  }
  appname=$(echo -n "${appname}" | head -n1 | cut -d= -f2)
  
  #-----------------------------------------------------------------------------------------------------------------
  
  appcomment=$(grep -A 10000 "\[Desktop Entry]" "${desktop_file}" | grep -m1 ^"Comment\[$(echo ${LANG} | cut -d. -f1)]=")
  [ -z "${appname}" ] && {
    appcomment=$(grep -A 10000 "\[Desktop Entry]" "${desktop_file}" | grep -m1 ^"Comment=")
  }
  appcomment=$(echo -n "${appcomment}" | head -n1 | cut -d= -f2)
  
  #-----------------------------------------------------------------------------------------------------------------
  
  appversion=$(grep "X-AppImage-Version" "${desktop_file}" | cut -c 20-)
  [ -z "${appversion}" ] && {
    appversion=$(echo "${hash}" | cut -c 1-6)
  }
  
  #-----------------------------------------------------------------------------------------------------------------
  
  package_name=$(echo ${appname} | tr '[[:space:]]' '-' \
                                 | tr '[[:upper:]]' '[[:lower:]]' \
                                 | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/')
  package_name="${package_name}appimage"
  
  #-----------------------------------------------------------------------------------------------------------------
  
  [ "${icon_file}" = "${HERE}/appimage-128.png" ] && {
    cp "${HERE}/appimage-128.png" "${data_dir}/.DirIcon.new"
    icon_file="${data_dir}/.DirIcon.new"
  } || {
    rsvg-convert -w 128 -h 128 "${icon_file}" -o "${icon_file}".render 2> /dev/null && {
      cp "${icon_file}".render "${icon_file}"
    }
    rm "${icon_file}".render
    "${HERE}/convert-im6.q16" -resize 128x128 "${icon_file}" "${icon_file}.new"
    "${HERE}/convert-im6.q16" -resize 64x64 "${icon_file}.new" "${icon_file}"
    cp "${icon_file}.new" "${data_dir}/.DirIcon.new"
  }
  cp "${data_dir}/.DirIcon.new" "${data_dir}/ICON"
  "${HERE}/convert-im6.q16" -resize 64x64 "${icon_file}" "${icon_file}.64.png"
  mv "${icon_file}.64.png" "${data_dir}/ICON_64"
  
  #-----------------------------------------------------------------------------------------------------------------
  
  echo ${appversion}   > "${data_dir}/VERSION"
  echo ${appname}      > "${data_dir}/APPNAME"
  echo ${package_name} > "${data_dir}/PACKAGENAME"
  echo ${hash}         > "${data_dir}/HASH"
  echo ${file_name}    > "${data_dir}/APPIMAGE_FILE"
  
  #-----------------------------------------------------------------------------------------------------------------
  
  echo ""                                       >  "${data_dir}/STATUS"
  echo "Package: ${package_name}"               >> "${data_dir}/STATUS"
  echo "Priority: optional"                     >> "${data_dir}/STATUS"
  echo "Status: install ok installed"           >> "${data_dir}/STATUS"
  echo "Version: 0${appversion}"                >> "${data_dir}/STATUS"
  echo "Architecture: amd64"                    >> "${data_dir}/STATUS"
  echo "Installed-Size: ${file_size}"           >> "${data_dir}/STATUS"
  echo "Maintainer: AppImage Installer"         >> "${data_dir}/STATUS"
  echo "Depends: dpkg"                          >> "${data_dir}/STATUS"
  echo "Description: ${appcomment}"             >> "${data_dir}/STATUS"
  echo ""                                       >> "${data_dir}/STATUS"
  
  #-----------------------------------------------------------------------------------------------------------------

  echo "/."                                                        >> "${data_dir}/LIST"
  echo "/usr"                                                      >> "${data_dir}/LIST"
  echo "/usr/share"                                                >> "${data_dir}/LIST"
  echo "/usr/share/applications"                                   >> "${data_dir}/LIST"
  echo "/usr/share/applications/${package_name}.desktop"           >> "${data_dir}/LIST"
  echo "/usr/share/icons"                                          >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor"                                  >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor/64x64"                            >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor/64x64/apps"                       >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor/64x64/apps/${package_name}.png"   >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor/128x128"                          >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor/128x128/apps"                     >> "${data_dir}/LIST"
  echo "/usr/share/icons/hicolor/128x128/apps/${package_name}.png" >> "${data_dir}/LIST"
  echo "/opt"                                                      >> "${data_dir}/LIST"
  echo "/opt/appimages-installed"                                  >> "${data_dir}/LIST"
  echo "/opt/appimages-installed/${hash}"                          >> "${data_dir}/LIST"
  
  #-----------------------------------------------------------------------------------------------------------------
  
  mv "${desktop_file}" "${data_dir}/LAUNCHER"
  execline=$(grep -E '^Exec\=' "${data_dir}/LAUNCHER" | cut -c 6- | cut -d' ' -f1)
  
  sed -i "s|^Exec=${execline}|Exec=/opt/appimages-installed/${hash}|g" "${data_dir}/LAUNCHER"  
  sed -i "s|^TryExec=.*|TryExec=/opt/appimages-installed/${hash}|g"    "${data_dir}/LAUNCHER"
  sed -i "s|^Icon=.*|Icon=${package_name}|g"                           "${data_dir}/LAUNCHER"
  
  #-----------------------------------------------------------------------------------------------------------------

}

[ "${1}" == "--ok-procced-to-installation" ] && {
  [ -f "${2}/STATUS" ] && {
    data_dir="${2}"
    cd "${data_dir}"
    
    mkdir -p "/usr/share/applications/"
    mkdir -p "/opt/appimages-installed/"
    mkdir -p "/usr/share/icons/hicolor/64x64/apps/"
    mkdir -p "/usr/share/icons/hicolor/128x128/apps/"
    mkdir -p "/var/lib/dpkg/info/"
    mkdir -p "/var/lib/app-info/icons/appimages-$(cat PACKAGENAME)/128x128/"
    mkdir -p "/var/lib/app-info/icons/appimages-$(cat PACKAGENAME)/64x64/"
    
    mv  "LAUNCHER"             "/usr/share/applications/$(cat PACKAGENAME).desktop"
    cp  "ICON_64"              "/usr/share/icons/hicolor/64x64/apps/$(cat PACKAGENAME).png"
    cp  "ICON"                 "/usr/share/icons/hicolor/128x128/apps/$(cat PACKAGENAME).png"
    cp  "$(cat APPIMAGE_FILE)" "/opt/appimages-installed/$(cat HASH)"
    
    chmod +x  "/opt/appimages-installed/$(cat HASH)"
    
    cp  "LIST"                 "/var/lib/dpkg/info/$(cat PACKAGENAME).list"
    cat "STATUS" >>            "/var/lib/dpkg/status"
    exit 0
  }
  exit 1
}


file_name=$(readlink -f "${1}")
base_file_name=$(basename "${file_name}")

[ ! -f "${file_name}" ] && {
  echo "File '${1}' not found"
  exit 1
}

offset=$(grep -oab "hsqs" "${file_name}"  | cut -d\: -f1 | tail -n1)

[ "${offset}" = "" ] && {
  echo "File '${1}' is not a valid AppImage"
}

data_dir="$(mktemp -d)"
installer_picture="${HERE}/appimage-128.png"

getData | yad --progress --auto-close --pulsate    --progress-text=" "                  \
              --center   --borders=32 --no-buttons --window-icon="${HERE}/appimage.png" \
              --text="Obtendo informações de '${base_file_name}'"
              

installed_version=$(grep -A 8 ^"Package: $(cat ${data_dir}/PACKAGENAME)"$ /var/lib/dpkg/status | grep ^Version: | cut -d ' ' -f2 | cut -c 2-)

[ "${installed_version}" = "$(cat ${data_dir}/VERSION)" ] && {
  yad --center --fixed --borders=32 --text="<big><b>A mesma versão de '$(cat ${data_dir}/APPNAME)' está instalada</b>\n</big>\n\n<big>O programa será desinstalado e instalado novamente!\nDeseja prosseguir?</big>\n" --image="${data_dir}/.DirIcon.new" --window-icon="${HERE}/appimage.png" --image-on-top --button=gtk-no:1 --button=gtk-yes:0 --title="Instalação de aplicativo AppImage" || exit
  pkexec $(which dpkg) -r "$(cat ${data_dir}/PACKAGENAME)" || {
    [ ! -z "${data_dir}" ] && rm -rf "${data_dir}"
    exit 1
  }
}


grep -q ^"Package: $(cat ${data_dir}/PACKAGENAME)"$ /var/lib/dpkg/status && {
  yad --center --fixed --borders=32 --text="<big><b>O aplicativo '$(cat ${data_dir}/APPNAME)' já está instalado!</b>\n</big>\nVersão instalada: ${installed_version}\nNova versão: $(cat ${data_dir}/VERSION)\n\n<big>Deseja remover a versão já instalada para prosseguir\ncom a instalação?</big>\n" --image="${data_dir}/.DirIcon.new" --window-icon="${HERE}/appimage.png" --image-on-top --button=gtk-no:1 --button=gtk-yes:0 --title="Instalação de aplicativo AppImage" || exit
  
  pkexec $(which dpkg) -r "$(cat ${data_dir}/PACKAGENAME)" || {
    [ ! -z "${data_dir}" ] && rm -rf "${data_dir}"
    exit 1
  }
}


yad --center --fixed --borders=32 --width=640 \
    --text=" <big><b>Bem vido(a) a instalação do\n $(cat ${data_dir}/APPNAME)</b>\n</big>\n  Versão: $(cat ${data_dir}/VERSION)\n\n <big> Deseja prosseguir com a instalação?</big>\n" \
    --image="${data_dir}/.DirIcon.new" --image-on-top --button=gtk-no:1 --button=gtk-yes:0 \
    --title="Instalação de aplicativo AppImage" --window-icon="${HERE}/appimage.png" && {
    
    pkexec "${SELF}" "--ok-procced-to-installation" "${data_dir}"
} || exit 0

yad --center --fixed --borders=32 --width=640 --text="<big><b>Instalação bem sucedida</b>\n</big>\n<big>Deseja Executar o programa agora?</big>\n" --image="${data_dir}/.DirIcon.new" --image-on-top --button=gtk-no:1 --window-icon="${HERE}/appimage.png" --button=gtk-yes:0 --title="Instalação de aplicativo AppImage" && \
     "/opt/appimages-installed/$(cat "${data_dir}/HASH")" 

[ ! -z "${data_dir}" ] && rm -rf "${data_dir}"

[ -f "${HOME}/.cache/mintinstall/pkginfo.json" ] && {
  rm "${HOME}/.cache/mintinstall/pkginfo.json"
}
