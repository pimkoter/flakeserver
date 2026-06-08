{
  flake.nixosModules.autoUpgrade = {admin, ...}: {
    system.autoUpgrade = {
      enable = true;
      flake = admin.gitChannel;
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
  };
}
