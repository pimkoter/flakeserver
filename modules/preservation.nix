{
  inputs,
  self,
  ...
}: {
  inputs.flake.nixosModules.preservation = {pkgs, ...}: {
    imports = [
      inputs.preservation.nixosModules.preservation
    ];

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
