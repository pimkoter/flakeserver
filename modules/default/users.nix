{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.users = {config, ...}: {
    users.users.${config.admin.name} = {
      isNormalUser = true;
      hashedPassword = config.admin.hashedPassword;
      extraGroups = ["wheel" "docker"];
    };
  };
}
