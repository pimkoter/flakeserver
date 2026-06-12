{
  config,
  lib,
  ...
}: let
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
in {
  options.settings = {
    # Host definities
    alpha = lib.mkOption {type = hostSettings;};
    beta = lib.mkOption {type = hostSettings;};
    gamma = lib.mkOption {type = hostSettings;};
    delta = lib.mkOption {type = hostSettings;};

    # Netwerk opties
    networking.nameServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };

    # Disk opties
    disk = {
      drive = lib.mkOption {type = lib.types.str;};
      mntPoint = lib.mkOption {type = lib.types.str;};
    };

    # Admin opties
    admin = {
      name = lib.mkOption {type = lib.types.str;};
      hashedPassword = lib.mkOption {type = lib.types.str;};
      domain = lib.mkOption {type = lib.types.str;};
      routerIp = lib.mkOption {type = lib.types.str;};
      gitHubAddr = lib.mkOption {type = lib.types.str;};
      flakeDir = lib.mkOption {type = lib.types.str;};
    };
  };

  config = {
    # Automatische PiHole detectie over alle hosts heen
    settings.networking.nameServers = let
      allHosts = builtins.attrValues config.settings.hosts;
      piHoleHost = lib.findFirst (h: h.isPiHole) null allHosts;
    in [
      (
        if piHoleHost != null
        then piHoleHost.ipAddr
        else "1.1.1.1"
      )
    ];
  };
}
