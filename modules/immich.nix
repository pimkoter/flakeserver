{
  self,
  inputs,
}: {
  flake.nixosModules.immich = let
    immichDir = "${self.settings.disk.mntPoint}/foto";
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
  };
}
