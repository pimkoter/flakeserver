{
  inputs,
  self,
  ...
}: {
  inputs.flake.nixosModules.preservation = {
    pkgs,
    config,
    ...
  }: {
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
