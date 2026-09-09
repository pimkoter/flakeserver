{
  flake.nixosModules.settings =
    { config, lib, ... }:
    {
      config = {
        settings = {
          hostName = lib.mkDefault "omega";

          hosts = {
            alpha = {
              hostName = "alpha";
              ipAddr = "192.168.178.2";
              isPiHole = true;
            };

            beta = {
              hostName = "beta";
              ipAddr = "192.168.178.3";
            };

            gamma = {
              hostName = "gamma";
              ipAddr = "192.168.178.4";
            };

            delta = {
              hostName = "delta";
              ipAddr = "192.168.178.5";
            };
          };

          disks = {
            system = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_250GB_S2R6NB0J375639P";
            media = "/dev/disk/by-uuid/af91dd32-6299-4eb5-982b-f111b7cca4e3";
            mntPoint = "/media";
          };

          network = {
            physicalInterface = "enp6s0";
          };

          admin = {
            hashedPassword = "$y$j9T$yMgfvvj7oXg25fspUIpvN0$Hv32VEd1FcaBhmA90kI9mfWzAJWp13ikJtj.8WfzYr.";
            gitHubAddr = "github.com/pimkoter/flakeserver";
          };
        };

        networking.nameservers =
          let
            allHosts = builtins.attrValues config.settings.hosts;
            piHoleHost = lib.findFirst (h: h.isPiHole) null allHosts;
          in
          [
            (if piHoleHost != null then piHoleHost.ipAddr else "1.1.1.1")
          ];
      };
    };
}
