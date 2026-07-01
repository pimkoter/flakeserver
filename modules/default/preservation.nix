{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.preservation = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.preservation.nixosModules.default
    ];

    preservation = {
      enable = true;

      preserveAt."/persistent" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/timers"
          "/etc/secureboot"
        ];

        files = [
          "/etc/machine-id"
        ];

        users.serveradmin = {
          directories = [
            "downloads"
            ".config/containers"
            ".ssh"
          ];
        };
      };
    };

    boot.initrd.supportedFilesystems = ["btrfs"];
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /tmpdir
      mount -t btrfs /dev/sda4 /tmpdir

      if [ -d /tmpdir/root ]; then
          echo "Safely clearing nested subvolumes inside root..."
          # Using awk ensures variable spacing in column 9 won't break the string target
          btrfs subvolume list -o /tmpdir/root | awk '{print $9}' | while read -r subvolume; do
              btrfs subvolume delete "/tmpdir/$subvolume"
          done

          echo "Wiping ephemeral root subvolume..."
          btrfs subvolume delete /tmpdir/root
      fi

      echo "Restoring pristine root from snapshot..."
      btrfs subvolume snapshot /tmpdir/root-blank /tmpdir/root

      umount /tmpdir
    '';
  };
}
