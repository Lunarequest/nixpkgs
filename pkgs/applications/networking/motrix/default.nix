{ stdenv, fetchurl, appimageTools, makeWrapper, electron_11 }:

stdenv.mkDerivation rec {
  pname = "motrix";
  version = "1.6.11";

  src = fetchurl {
    url =
      "https://github.com/agalwood/Motrix/releases/download/v${version}/Motrix-${version}.AppImage";
    sha256 = "0hsazragk4hf9hh1i1hnqhw48kl3f3sckapwzah06w9ysgn90kdl";
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
    cp -a ${appimageContents}/motrix.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons $out/share
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron_11}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${
        stdenv.lib.makeLibraryPath [ stdenv.cc.cc ]
      }"
  '';

  meta = with stdenv.lib; {
    description =
      "Motrix is a full-featured download manager that supports downloading HTTP, FTP, BitTorrent, Magnet, etc.";
    homepage = "https://motrix.app/";
    license = licenses.MIT;
    maintainers = with maintainers; [ lunarequest ];
    platforms = [ "x86_64-linux" ];
  };
}
