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

        users.pim = {
          directories = [
            "flakeserver"
            ".ssh"
          ];
        };
      };
    };

    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
    environment.etc."machine-id" = {
      neededForBoot = true;
    };

    boot.initrd = {
      supportedFilesystems = ["btrfs"];
      systemd.services.rollback = {
        description = "Wipe and rollback ephemeral BTRFS root subvolume to a pristine state";
        wantedBy = ["initrd.target"];

        after = ["initrd-root-device.target" "local-fs-pre.target"];
        before = ["sysroot.mount"];

        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";

        script = ''
          mkdir -p /tmpdir
          mount -t btrfs /dev/sda4 /tmpdir

          if [ -d /tmpdir/root ]; then
              echo "Safely clearing nested subvolumes inside root..."
              # Clean up potential nested subvolumes
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
    };
  };
}
