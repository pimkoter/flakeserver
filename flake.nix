{
  description = "KoterOS but flake-part based";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    preservation.url = "github:nix-community/preservation";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
  # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake {inherit inputs;} {
      inputs.import-tree =
        {
          src = ./.;
        }
        // {
          imports = [
            inputs.disko.flakeModules.default
            inputs.preservation.nixosModules.default
          ];
          systems = ["x86_64-linux"];
        };
    };
}
