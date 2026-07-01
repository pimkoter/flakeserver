{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.settings = {
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
    options = {
      settings.hostName = lib.mkOption {
        type = lib.types.str;
        description = "hostname";
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf hostSettings;
        default = {};
      };

      disks = {
        drive1 = lib.mkOption {type = lib.types.str;};
        drive2 = lib.mkOption {type = lib.types.str;};
        mntPoint = lib.mkOption {
          type = lib.types.str;
          default = "/media";
        };
      };

      admin = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "pim";
        };
        hashedPassword = lib.mkOption {type = lib.types.str;};
        domain = lib.mkOption {
          type = lib.types.str;
          default = "puber";
        };
        routerIp = lib.mkOption {
          type = lib.types.str;
          default = "192.168.178.1";
        };
        gitHubAddr = lib.mkOption {type = lib.types.str;};
        flakeDir = lib.mkOption {
          type = lib.types.str;
          default = "/home/pimkoter/flakeserver";
        };
      };
    };

    config = {
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
        drive1 = "/dev/sda";
        drive2 = "/dev/disk/by-uuid/af91dd32-6299-4eb5-982b-f111b7cca4e3";
      };

      admin = {
        hashedPassword = "$6$sIfjCM5qq91ch98l$ZPL9I/xe22Xdpe60QLDz3wStTxDqKIkvz8/KRh7YKOFN.d6YroSuQR.xIao0Zdg5u4XnBcurPd4i5RXtm1.qw1";
        gitHubAddr = "github.com/pimkoter/flakeserver";
      };

      networking.nameservers = let
        allHosts = builtins.attrValues config.hosts;
        piHoleHost = lib.findFirst (h: h.isPiHole) null allHosts;
      in [
        (
          if piHoleHost != null
          then piHoleHost.ipAddr
          else "1.1.1.1"
        )
      ];
    };
  };
}
