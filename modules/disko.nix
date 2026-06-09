{
  inputs,
  self,
}: let
  module = "disko";
in {
  inputs.flake.nixosModules.${module} = {pkgs, ...}: {
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    inputs.disko.devices.nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=25%"
          "mode=755"
        ];
      };
    };

    inputs.disko.devices.disk.main = {
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

      content.partitions.root = {
        name = "root";
        size = "100%";

        content = {
          type = "btrfs";
          extraArgs = ["-f"];

          subvolumes = {
            "/persistent" = {
              mountOptions = ["subvol=persistent" "noatime"];
              mountpoint = "/persistent";
            };

            "/nix" = {
              mountOptions = ["subvol=nix" "noatime"];
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
