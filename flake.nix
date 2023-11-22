{
  description = "A curated list of wallpapers with easy nix integration.";

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;

    foreachSystem = lib.genAttrs [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];

    props = builtins.fromJSON (builtins.readFile ./props.json);

    getCollections = prev: files: args:
      lib.mapAttrs (
        name: _:
          prev.callPackage ./package.nix (
            {
              collection = name;
            }
            // args
          )
      ) (lib.filterAttrs (_: type: type == "directory") files);
  in {
    overlays.default = _: prev: let
      stdenv = prev.stdenvNoCC;
      args = {
        inherit stdenv lib;
        inherit (props) version;
      };
    in
      {
        wallnix =
          prev.callPackage ./package.nix
          (
            {collection = null;} // args
          );
      }
      // (
        getCollections prev (builtins.readDir ./wallpapers) args
      );

    packages = foreachSystem (system:
      (self.overlays.default null nixpkgs.legacyPackages.${system})
      // {
        default = self.packages.${system}.wallnix;
      });

    formatter = foreachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
