{ lib, inputs, ... }: {
  imports = [ (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix") ];

  # Note: Run 'nixos-generate-config --show-hardware-config' on the target
  # and replace this with the generated content.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ]; # Or kvm-amd

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
