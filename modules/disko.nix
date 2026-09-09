{ inputs, ... }: {
  flake.nixosModules.disko =
    { config, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

      disko.devices = {
        disk = {
          main = {
            device = config.settings.disks.system;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  type = "EF00";
                  size = "500M";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };
}
