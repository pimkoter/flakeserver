{
  lib,
  config,
  ...
}: let
  # Generate setting options for every host
  hostSettings = lib.types.submodule {
    options = {
      hostName = lib.mkOption {type = lib.types.str;};
      ipAddr = lib.mkOption {type = lib.types.str;};
      isPiHole = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  # Generate PiHole DNS server
  allHosts = builtins.attrValues config.settings;
  piHoleHost = lib.findFirst (h: h.isPiHole) null allHosts;
  dnsServer =
    if piHoleHost != null
    then piHoleHost.ipAddr
    else "1.1.1.1";
in {
  options.settings = {
    alpha = lib.mkOption {type = hostSettings;};
    beta = lib.mkOption {type = hostSettings;};
    gamma = lib.mkOption {type = hostSettings;};
    delta = lib.mkOption {type = hostSettings;};

    networking = {
      nameServers = [dnsServer];
    };

    disk = {
      drive = "/dev/disk/by-uuid/af91dd32-6299-4eb5-982b-f111b7cca4e3";
      mntPoint = "/media";
    };

    admin = {
      name = "pim";
      domain = "puber";
    };
  };
}
