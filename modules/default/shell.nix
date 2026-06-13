{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.shell = {
    config,
    pkgs,
    ...
  }: {
    users.users.${config.admin.name}.shell = pkgs.zsh;
    programs.zsh = {
      enable = true;
      shellAliases = {
        v = "nvim";
        sv = "sudo nvim";
        c = "clear";
        ll = "ls -l";
        la = "ls -al";
        gens = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        upgrade = "git pull origin main && sudo nixos-rebuild switch --flake .#$(hostname)";
        test = "git pull origin test && sudo nixos-rebuild switch --flake .#$(hostname)";
      };
    };
  };
}
