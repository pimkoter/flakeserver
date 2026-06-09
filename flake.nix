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
  };

  outputs = inputs @ {flake-parts, ...}:
  # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.disko.flakeModules.default
        inputs.preservation.nixosModules.default
        (inputs.import-tree ./.)
      ];
      systems = ["x86_64-linux"];
    };
}
