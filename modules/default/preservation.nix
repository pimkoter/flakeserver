{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.preservation = {
    imports = [inputs.preservation.nixosModules.default];
    preservation = {
      enable = true;

      preserveAt."/persistent" = {
        directories = [
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];

        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];
      };
    };
  };
}
