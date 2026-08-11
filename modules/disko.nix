{ inputs, ... }: {
  flake.nixosModules.disko = { ... }: {
    imports = [ inputs.disko.nixosModules.disko ];
    disko.devices = {
      disk = {
        sda = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                priority = 1;
                name = "ESP";
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              swap = {
                priority = 2;
                size = "2G";
                content = {
                  type = "swap";
                  discardPolicy = "both";
                };
              };
              root = {
                priority = 3;
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
