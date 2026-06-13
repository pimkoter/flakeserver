{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.users = {
    users.users = {
      ${self.nixosModules.settings.admin.name} = {
        isNormalUser = true;
        hashedPassword = self.nixosModules.settings.admin.hashedPassword;
        extraGroups = ["wheel"];
      };
    };
  };
}
