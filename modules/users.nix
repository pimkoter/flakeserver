{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.users = { config, ... }: {
    users.users.${config.settings.admin.name} = {
      isNormalUser = true;
      hashedPassword = config.settings.admin.hashedPassword;
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };
}
