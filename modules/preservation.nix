{
  inputs,
  self,
}: let
  module = "preservation";
in {
  inputs.flake.nixosModules.${module} = {pkgs, ...}: {
    boot.tmp.cleanOnBoot = true;
    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
        directories = [
          "/tmp"
        ];
      };
    };
  };
}
