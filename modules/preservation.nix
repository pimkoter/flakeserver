{
  flake.nixosModules.preservation = {admin, ...}: {
    boot.tmp.cleanOnBoot = true;
    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
        directories = [
          "/var/lib/tailscale"
          "/var/log"
          "/tmp"
        ];

        users.${admin.name} = {
          directories = [
            "${admin.flakeDir}"
          ];
        };
      };
    };
  };
}
