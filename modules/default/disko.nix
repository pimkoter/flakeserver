{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.disko = {
    imports = [inputs.disko.nixosModules.disko];

    fileSystems."/".neededForBoot = true;
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    disko.devices.disk.main = {
      device = "/dev/sda";
      type = "disk";
      content.type = "gpt";

      content.partitions.boot = {
        name = "boot";
        size = "1M";
        type = "EF02";
      };

      content.partitions.esp = {
        name = "ESP";
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };

      content.partitions.swap = {
        size = "4G";
        content = {
          type = "swap";
          resumeDevice = true;
        };
      };

      content.partitions.root = {
        name = "root";
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = ["-f"];

          subvolumes = {
            "/" = {
              mountOptions = ["subvol=root" "noatime" "compress=zstd"];
              mountpoint = "/";
            };

            "/root-blank" = {
              mountOptions = ["subvol=root-blank" "noatime" "compress=zstd"];
              mountpoint = null;
            };

            "/nix" = {
              mountOptions = ["subvol=nix" "noatime" "compress=zstd"];
              mountpoint = "/nix";
            };

            "/persistent" = {
              mountOptions = ["subvol=persistent" "noatime" "compress=zstd"];
              mountpoint = "/persistent";
            };
          };
        };
      };
    };
  };
}
