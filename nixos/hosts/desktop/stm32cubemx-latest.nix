# stm32cubemx-latest.nix
{ lib, stdenvNoCC, fetchzip, jdk21, buildFHSEnv, makeDesktopItem
, icoutils, imagemagick, fdupes }:
let
  version = "6.18.1";
  package = stdenvNoCC.mkDerivation rec {
    pname = "stm32cubemx";
    inherit version;
    src = fetchzip {
      url = "https://sw-center.st.com/packs/resource/library/stm32cube_mx_v${builtins.replaceStrings ["."] [""] version}-lin.zip";
      sha256 = "sha256-Enpc4HFLjQRwovk8/9xCpDZZrmcRLlblY/RNqXbMbsM=";
      stripRoot = false;
    };
    nativeBuildInputs = [ icoutils imagemagick fdupes ];
    desktopItem = makeDesktopItem {
      name = "STM32CubeMX";
      exec = "stm32cubemx";
      desktopName = "STM32CubeMX";
      categories = [ "Development" ];
      icon = "stm32cubemx";
      terminal = false;
    };
    buildCommand = ''
      mkdir -p $out/{bin,opt/STM32CubeMX,share/applications}
      cp -r $src/MX/. $out/opt/STM32CubeMX/
      chmod +rx $out/opt/STM32CubeMX/STM32CubeMX
      cat << EOF > $out/bin/${pname}
      #!${stdenvNoCC.shell}
      ${jdk21}/bin/java -jar $out/opt/STM32CubeMX/STM32CubeMX
      EOF
      chmod +x $out/bin/${pname}
      cp ${desktopItem}/share/applications/*.desktop $out/share/applications

      ICO=$(find $out/opt/STM32CubeMX -iname '*.ico' -not -path '*Uninstaller*' | head -n1)
      if [ -n "$ICO" ]; then
        icotool --extract "$ICO" 2>/dev/null || true
        fdupes -dN . > /dev/null

        SRC=$(find . -maxdepth 1 -iname '*_256x256x32.png' -print -quit)
        if [ -z "$SRC" ]; then
          # no exact 256x256x32 frame — fall back to whichever extracted png is largest
          SRC=$(find . -maxdepth 1 -iname '*.png' -printf '%s %p\n' 2>/dev/null \
                | sort -rn | head -n1 | cut -d' ' -f2-)
        fi

        if [ -n "$SRC" ]; then
          for size in 16 24 32 48 64 128 256; do
            mkdir -pv $out/share/icons/hicolor/"$size"x"$size"/apps
            magick "$SRC" -resize "$size"x"$size" \
              $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
          done
        else
          echo "warning: icotool produced no usable png frames, skipping icon"
        fi
      else
        echo "warning: no non-uninstaller .ico found under STM32CubeMX install tree, skipping icon"
      fi
    '';
    meta = {
      description = "STM32CubeMX, pinned newer than nixpkgs";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
in
buildFHSEnv {
  inherit (package) pname version meta;
  runScript = "${package}/bin/stm32cubemx";
  targetPkgs = pkgs: with pkgs; [
    alsa-lib at-spi2-atk cairo cups dbus expat glib gtk3 libdrm libGL
    libxkbcommon mesa nspr nss pango
    libx11 libxcb libxcomposite libxdamage
    libxext libxfixes libxrandr
  ];
  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons
    cp ${package}/share/applications/*.desktop $out/share/applications/
    cp -r ${package}/share/icons/* $out/share/icons/ 2>/dev/null || true
  '';
}
