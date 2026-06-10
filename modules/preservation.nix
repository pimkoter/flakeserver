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
    ...
  }: {
    boot.initrd.systemd.enable = true;
    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        files = [
          {
            file = "/etc/machine-id";
          }
        ];
        directories = [
          "/tmp"
        ];
      };
    };
  };
}
