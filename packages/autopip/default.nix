{ stdenvNoCC, fetchurl, undmg }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "autopip";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/vordenken/AutoPiP/releases/download/v${finalAttrs.version}/AutoPiP.dmg";
    hash = "sha256-H3oPZHxXe0TlHQrF5FCAQ2mtqdUi11/kNxhV1edo8Bo=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R AutoPiP.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Safari extension for automatic Picture-in-Picture video playback";
    homepage = "https://github.com/vordenken/AutoPiP";
    platforms = [ "aarch64-darwin" ];
    mainProgram = "AutoPiP";
  };
})
