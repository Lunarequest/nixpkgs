{ lib, stdenv, fetchgit, kernel, bc, nukeReferences }:
let
  commit = "cb152fdada53528682cac9b5d70f8fc22ed58361";
in
stdenv.mkDerivation rec {
  pname = "keymash";
  version = "${kernel.version}-${commit}";
  src = fetchgit {
    url = "https://git.bsd.gay/fef/keymash.git";
    rev = commit;
    sha256 = "0swqjbsjm13l9n89xj4n37qczj68ga9xj7g7yxwcx6lsr62pk2px";
  };

  nativeBuildInputs = [ bc nukeReferences ];
  buildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = [ "pic" "format" ];

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace '$(shell uname -r)' "${kernel.modDirVersion}" \
  '';

  preInstall = ''
     mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/char/"
  '';

  postInstall = ''
    nuke-refs $out/lib/modules/*/kernel/drivers/char/*.ko
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Device driver that provides an endless supply of lowercase characters from the QWERTY home row in a cryptographically secure random order.";
    homepage = "https://git.bsd.gay/fef/keymash";
    license = [ licenses.gpl2Only licenses.bsd0 ];
    maintainers = with maintainers; [ lunarequest ];
  };
}
