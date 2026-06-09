{
  inputs,
  self,
  ...
}: {
  inputs.flake.nixosModules.users = {pkgs, ...}: {
    users.users = {
      pim = {
        extraGroups = ["wheel"];
        isNormalUser = true;
        shell = pkgs.zsh;
        home = "/home/pim";
        createHome = true;
        initialPassword = "koter";
        autoSubUidGidRange = true;
      };
    };
  };
}
