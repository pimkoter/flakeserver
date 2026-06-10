{
  inputs,
  self,
  config,
  pkgs,
  ...
}: {
  inputs.flake.nixosModules.preservation = {
    config,
    pkgs,
    lib,
    ...
  }: {
    config.boot.initrd.systemd.enable = true;
    config.preservation = {
      enable = true;
      preserveAt."/persistent" = {
        files = [
          {
            file = "/etc/machine-id";
            initrd = true;
          }
        ];
        directories = [
          "/tmp"
        ];
      };
    };
  };
}
