{
  flake.nixosModules.common = {
    lib,
    pkgs,
    admin,
    name,
    ...
  }: {
    users.users.${admin.name} = {
      isNormalUser = true;
      hashedPassword = "${admin.pswd}";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      shell = pkgs.zsh;
    };

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
    };

    networking = {
      hostName = lib.mkDefault name;
      networkmanager.enable = lib.mkDefault false;
      firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
        allowedTCPPorts = lib.mkDefault [80 443];
      };
    };

    services = {
      tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
      };
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
        };
      };
      fail2ban = {
        enable = true;
        bantime = "10m";
        bantime-increment.factor = "6";
      };
      resolved.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ripgrep
      neovim
      git
      lazydocker
      lazygit
    ];

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

    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
    };

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      download-buffer-size = 524288000;
    };

    nixpkgs.config = {
      allowUnfree = true;
    };

    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    system.stateVersion = "25.11";
  };
}
