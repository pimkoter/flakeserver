{
  self,
  inputs,
}: {
  flake.nixosModules.autoUpgrade = {
    system.autoUpgrade = {
      enable = true;
      flake = self.settings.admin.gitHubAddr;
      allowReboot = true;
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
      flags = [
        "--print-build-logs"
      ];
      dates = "03:00";
      randomizedDelaySec = "1h";
    };

    nix = {
      gc = {
        automatic = true;
        dates = "06:00";
        options = "--delete-older-than 7d";
        randomizedDelaySec = "1h";
      };
      optimise = {
        automatic = true;
        dates = "07:30";
        randomizedDelaySec = "30m";
      };
    };
  };
}
