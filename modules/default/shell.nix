{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.shell = {pkgs, ...}: {
    users.users.${self.admin.name}.shell = pkgs.zsh;
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
        upgrade = "cd ${self.settings.admin.flakeDir} && git pull origin main && sudo nixos-rebuild switch --flake .#$(hostname)";
        test = "cd ${self.settings.admin.flakeDir} && git pull origin test && sudo nixos-rebuild switch --flake .#$(hostname)";
      };
    };
  };
}
