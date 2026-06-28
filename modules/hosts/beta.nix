{
  self,
  inputs,
  ...
}: let
  name = "beta";
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
      vaultWarden
      immich
      drive
    ];
  };
}
