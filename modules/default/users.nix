{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.users = {
    users.users = {
      ${self.settings.admin.name} = {
        isNormalUser = true;
        hashedPassword = self.settings.admin.hashedPassword;
        extraGroups = ["wheel"];
      };
    };
  };
}
