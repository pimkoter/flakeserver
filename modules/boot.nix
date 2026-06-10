{
  inputs,
  self,
  ...
}: let
  module = "boot";
in {
  inputs.flake.nixosModules.${module} = {pkgs, ...}: {
    boot = {
      initrd.systemd.enable = true;
      loader = {
        systemd-boot.enable = true;
        efi.canTouchVariables = true;
      };
    };
  };
}
