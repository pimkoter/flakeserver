{ inputs, ... }: {
  flake.nixosModules.boot = {
    imports = [
      "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    ];
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
