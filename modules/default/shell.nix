{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.shell = {pkgs, ...}: {
    users.users.pim.shell = pkgs.zsh;
    programs.zsh = {
      enable = true;
      shellInit = ''
        if [[ $- == *i* ]]; then
          echo welcome to ${name}
        fi
      '';

      shellAliases = {
        v = "nvim";
        sv = "sudo nvim";
        c = "clear";
        ll = "ls -l";
        la = "ls -al";
        gens = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        upgrade = "cd ${admin.flakeDir} && git pull origin main && sudo nixos-rebuild switch --flake .#${name}";
        test = "cd ${admin.flakeDir} && git pull origin test && sudo nixos-rebuild switch --flake .#${name}";
      };
    };
  };
}
