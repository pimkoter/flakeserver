{
  inputs,
  self,
  ...
}: let
  module = "boot";
in {
  inputs.flake.nixosModules.${module} = {pkgs, ...}: {
    boot = {
      tmp.cleanOnBoot = true;
      loader = {
        systemd-boot.enable = true;
        efi.canTouchVariables = true;
      };
    };
  };
}
