{
  inputs,
  self,
  ...
}: let
  module = "boot";
in {
  inputs.flake.nixosModules.${module} = {pkgs, ...}: {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchVariables = true;
    };
  };
}
