{
  self,
  inputs,
  ...
}:
let
  name = "omega";
in
{
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs self;
    };
    modules = with self.nixosModules; [
      { settings.hostName = name; }
      # Default modules
      boot
      disko
      miscellaneous
      networking
      pkgs
      shell
      users
      settings
      secrets

      # Host specific modules
      hypervisor
      proxy
      ./_hardware.nix
    ];
  };
}
