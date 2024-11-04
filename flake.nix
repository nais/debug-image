{
  description = "Nais debug image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        inherit (pkgs) lib;

        dockerTag = if lib.hasAttr "rev" self then
          "${builtins.toString self.revCount}-${self.shortRev}"
        else
          "gitDirty";

        # Compile workspace code (including 3rd party dependencies)
      in {
        devShell = pkgs.mkShell { buildInputs = with pkgs; [ just ]; };
        packages = rec {
          default = image;
          image = pkgs.dockerTools.buildImage {
            name = "nais-debug";
            tag = "docker";
            copyToRoot = pkgs.buildEnv {
              name = "packages";
              paths = with pkgs; [
                bash
                curl
                wget
                #                iproute2 # For 'ip' command and other networking tools.
                inetutils # For 'ping', 'traceroute', and other networking tools.
                netcat
                dnsutils # For 'dig' and 'nslookup'.
                htop
                #               strace
                lsof
                jq
                yq
                python3
                vim
                coreutils # For common Unix commands like 'cat', 'ls', etc.
                util-linux # Provides tools like 'lsblk', 'fdisk', 'more'.
                procps # For 'ps', 'top', etc.
                nmap
                tcpdump
                #   dstat
                zip
                unzip
              ];
              pathsToLink = [ "/bin" ];
            };
            config.Entrypoint = [ "bash" ];
          };
        };

        # Now `nix fmt` works!
        formatter = pkgs.alejandra;
      });
}
