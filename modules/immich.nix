{
  flake.nixosModules.immich = let
    immichDir = "/media/foto";
  in {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      mediaLocation = "${immichDir}";
    };

    systemd.services = {
      immich-server.serviceConfig.ReadWritePaths = ["${immichDir}"];
      immich-microservices.serviceConfig.ReadWritePaths = ["${immichDir}"];
      immich-machine-learning.serviceConfig.ReadWritePaths = ["${immichDir}"];
    };

    config.ports = [2283];
  };
}
