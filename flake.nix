{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      mac-app-util,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      home-manager,
      ...
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {

          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            vim
            vscode
            discord
            flameshot
            nil
            nixfmt-rfc-style
            zoom-us
            ghostty
            coreutils
            findutils
            spotify
          ];

          environment.variables = {
            EDITOR = "vim";
          };

          fonts.packages = with pkgs; [
            fira-code
          ];

          homebrew = {
            enable = true;
            # cli apps
            brews = [
              "mas"
            ];
            # gui apps
            casks = [
              "linearmouse"
              "firefox"
              "logi-options+"
              "pycharm"
              "datagrip"
              "microsoft-teams"
              "bitwarden"
              "chatgpt"
              "orcaslicer"
              "balenaetcher"
              "via"
              "orbstack"
              "autodesk-fusion"
              "parsec"
            ];
            # app store apps
            masApps = {
              # "MS Word" = 462054704;
              "MS Excel" = 462058435;
              # "MS PowerPoint" = 462062816;
              "MS OneNote" = 784801555;
              "MS Outlook" = 985367838;
              "RD Client" = 1295203466; # aka "Windows App"
            };

            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          system = {
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 5;

            defaults = {
              ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
              finder = {
                FXPreferredViewStyle = "clmv";
                AppleShowAllExtensions = true; # idk why this is here and below as well

              };
              loginwindow.GuestEnabled = false;
              NSGlobalDomain = {
                AppleInterfaceStyle = "Dark";
                ApplePressAndHoldEnabled = false;
                # AppleShowAllExtensions = true;
                InitialKeyRepeat = 25;
                KeyRepeat = 2;
              };
            };
          };

          networking = {
            hostName = "macmini";
          };

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          programs.fish.enable = true;
          environment.shells = [ pkgs.fish ];

          users.knownUsers = [ "dsluo" ];

          users.users.dsluo = {
            home = "/Users/dsluo";
            shell = pkgs.fish;
            uid = 501;
          };
        };

    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#macmini
      darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "dsluo";

              mutableTaps = false;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dsluo = import ./home.nix;
          }
        ];
      };
    };
}
