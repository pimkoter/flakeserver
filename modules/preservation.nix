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
