{ inputs, ... }: {
  flake.nixosModules.secrets = { config, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/var/lib/sops-nix/key.txt";
      gnupg.sshKeyPaths = [ ];

      secrets = {
        "pihole/pwhash" = { };
        "admin/password" = {
          neededForUsers = true;
        };
        "tailscale/authkey" = { };
      };
    };
  };
}
