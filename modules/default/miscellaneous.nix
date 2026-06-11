{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.miscellaneous = {lib, ...}: {
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    nix.settings.experimental-features = ["nix-command" "flakes"];
  };
}
