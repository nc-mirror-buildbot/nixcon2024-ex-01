{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=24.05";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      nixpkgs,
      treefmt-nix,
      self,
      ...
    }:
    let
      treefmtModule = {
        projectRootFile = "flake.nix";
        programs.nixfmt-rfc-style.enable = true;
      };
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      checks = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          treefmt = (treefmt-nix.lib.evalModule pkgs treefmtModule).config.build.check self;
          # packageTest = packageTest;
        }
      );

      formatter = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (treefmt-nix.lib.evalModule pkgs treefmtModule).config.build.wrapper
      );
    };
}
