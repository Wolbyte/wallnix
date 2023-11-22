{
  stdenv,
  lib,
  collection ? null,
  version,
  ...
}:
stdenv.mkDerivation {
  pname = "wallnix";
  inherit version;

  strictDeps = true;

  src = ./wallpapers;

  configurePhase = ''
    runHook preConfigure
    mkdir -p $out/share/wallpapers
    runHook postConfigure
  '';

  installPhase = let
    installWallpapers =
      if collection != null
      then "cp -r ./${collection} $out/share/wallpapers"
      else "cp -r ./* $out/share/wallpapers";
  in ''
    runHook preInstall
    ${installWallpapers}
    runHook postInstall
  '';

  meta = {
    description = "A curated collection of wallpapers with easy nix integration";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
