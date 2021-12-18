{ stdenv, fetchurl, appimageTools, makeWrapper, electron_14 }:

let electron = electron_14;
in stdenv.mkDerivation rec {
  pname = "Joplin";
  version = "2.6.9";

  src = fetchurl {
    url =
      "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}.AppImage";
    sha256 = "0wrmg44m54cyd7083375c512dqsc9s2nvhczwc7yr2bnv902g44f";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/${pname} $out/share/applications
    cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimageContents}/Joplin.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons $out/share
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${
        stdenv.lib.makeLibraryPath [ stdenv.cc.cc ]
      }"
  '';

  meta = with stdenv.lib; {
    description =
      "Joplin - an open source note taking and to-do application with synchronization capabilities for Windows, macOS, Linux, Android and iOS. Forum:";
    homepage = "https://joplinapp.org/";
    license = licenses.MIT;
    maintainers = "@lunarequest";
    platforms = [ "x86_64-linux" ];
  };
}
