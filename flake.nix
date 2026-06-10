{
  description = "KoterOS but flake-part based";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    import-tree.url = "github:vic/import-tree";
    preservation.url = "github:nix-community/preservation";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.disko.flakeModules.default
        inputs.preservation.nixosModules.default
      ];
      modules = [
        (inputs.import-tree ./modules)
        (inputs.import-tree ./hosts)
      ];
      systems = ["x86_64-linux"];
    };
}
