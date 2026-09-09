{
  self,
  inputs,
  ...
}:
let
  name = "gamma";
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
      miscellaneous
      networking
      pkgs
      shell
      users
      settings
      guest-common

      # Host specific modules
      jellyStack
      mediaDrive
      ./_hardware.nix
    ];
  };
}
