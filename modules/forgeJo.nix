{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.forgeJo = {
    services.forgejo = {
      enable = true;
      database.type = "postgres";
      lfs.enable = true;
      settings = {
        service.DISABLE_REGISTRATION = false;
      };
    };
  };
}
