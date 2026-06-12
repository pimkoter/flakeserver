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
        server = {
          DOMAIN = "forgeJo.${self.settings.admin.domain}";
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://${srv.DOMAIN}/";
          HTTP_PORT = 3000;
        };
        service.DISABLE_REGISTRATION = false;
      };
    };
  };
}
