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
        packages = rec {
          default = image;
          image = pkgs.dockerTools.buildImage {
            name = "europe-north1-docker.pkg.dev/nais-io/nais/images/debug";
            tag = "latest";
            copyToRoot = pkgs.buildEnv {
              name = "packages";
              paths = with pkgs; [
                bash
                kcat
                curl
                wget
                iproute2
                inetutils
                netcat
                dnsutils
                htop
                strace
                lsof
                jq
                yq
                python3
                vim
                coreutils
                util-linux
                procps
                nmap
                tcpdump
                dstat
                zip
                unzip
              ];
              pathsToLink = [ "/bin" ];
            };
            config = {
              Entrypoint = [ "bash" ];
               User = "1069";
            }
          };
        };

        formatter = pkgs.alejandra;
      });
}
