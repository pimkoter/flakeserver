{
  flake.nixosModules.autoGarbage = {
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
