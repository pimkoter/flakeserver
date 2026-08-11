{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.miscellaneous = {
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
