{
  flake.nixosModules.settings =
    {
      config,
      lib,
      ...
    }:
    let
      hostSettings = lib.types.submodule {
        options = {
          hostName = lib.mkOption { type = lib.types.str; };
          ipAddr = lib.mkOption { type = lib.types.str; };
          isPiHole = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };
    in
    {
      options = {
        settings.hostName = lib.mkOption {
          type = lib.types.str;
          description = "hostname";
        };

        hosts = lib.mkOption {
          type = lib.types.attrsOf hostSettings;
          default = { };
        };

        admin = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "pim";
          };
          hashedPassword = lib.mkOption { type = lib.types.str; };
          domain = lib.mkOption {
            type = lib.types.str;
            default = "puber";
          };
          routerIp = lib.mkOption {
            type = lib.types.str;
            default = "192.168.178.1";
          };
          gitHubAddr = lib.mkOption { type = lib.types.str; };
          flakeDir = lib.mkOption {
            type = lib.types.str;
            default = "/home/pimkoter/flakeserver";
          };
        };
      };
    };
}
