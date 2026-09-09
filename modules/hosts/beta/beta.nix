{
  self,
  inputs,
  ...
}:
let
  name = "beta";
in
{
  flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs self;
    };
    modules =
      with self.nixosModules;
      [
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
        immich
        vaultWarden
        homeAssistant
        mediaDrive
        ./_hardware.nix
      ];
  };
}
