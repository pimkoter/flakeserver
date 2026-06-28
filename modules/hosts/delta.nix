{
  self,
  inputs,
  ...
}: let
  name = "delta";
in {
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      # Default modules
      autoUpgrade
      boot
      disko
      miscellaneous
      networking
      pkgs
      preservation
      shell
      users
      settings

      # Host specific modules
      exitNode
    ];
  };
}
