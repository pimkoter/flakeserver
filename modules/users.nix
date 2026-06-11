{
  self,
  inputs,
}: {
  flake.nixosModules.users = {
    users.users.pim = {
      isNormalUser = true;
      initialPassword = "pimiseenleukejongen";
      extraGroups = ["wheel"];
    };
  };
}
