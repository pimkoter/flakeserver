{
  description = "Koter's original love";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    preservation.url = "github:nix-community/preservation";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.top@
    {
      config,
      settings,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = with inputs; [
        (import-tree ./modules)
        disko.flakeModules.default
        preservation.nixosModules.default
      ];
      systems = [
        "x86_64-linux"
      ];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        # Recommended: move all package definitions here.
        # e.g. (assuming you have a nixpkgs input)
        # packages.foo = pkgs.callPackage ./foo/package.nix { };
        # packages.bar = pkgs.callPackage ./bar/package.nix {
        #   foo = config.packages.foo;
        # };
      };
    };
}
