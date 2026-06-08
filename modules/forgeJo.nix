{
  flake.nixosModules.forgeJo = {
    services = {
      forgejo = {
        enable = true;
        stateDir = "/forgejo";
        useWizard = true;
      };
    };

    config.ports = [3000];
  };
}
