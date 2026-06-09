{
  inputs,
  self,
  ...
}: {
  inputs.flake.nixosModules.preservation = {pkgs, ...}: {
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
          "/tmp"
        ];
      };
    };
  };
}
