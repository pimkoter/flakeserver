{
  flake.nixosModules.nextCloud = {pkgs, ...}: {
    services = {
      nextcloud = {
        enable = true;
        hostName = "192.168.178.3";
        appstoreEnable = true;
        config = {
          adminpassFile = "/etc/nextcloud-admin-pass";
          dbtype = "sqlite";
        };
        datadir = "/nextcloud";
        settings.trusted_domains = ["tailscale0"];
      };
    };
    environment.etc."nextcloud-admin-pass".text = "pimiseenleukejongen";

    config.ports = [9205];
  };
}
