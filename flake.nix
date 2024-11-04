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
              paths = let
                networkTools = with pkgs; [
                  curlFull
                  dnsutils
                  inetutils
                  iproute2
                  lsof
                  netcat
                  nmap
                  openssl
                  socat
                  tcpdump
                  wget
                ];
                shellTools = with pkgs; [
                  coreutils
                  gnugrep
                  htop
                  jq
                  procps
                  python3
                  ripgrep
                  unzip
                  util-linux
                  vim
                  yq
                  zip
                ];
                persistenceTools = with pkgs; [ redis ];
                binaryTools = with pkgs; [ dstate strace ];
                dockerEnv = with pkgs; [
                  dockerTools.binEnv
                  dockerTools.binSh
                  dockerTools.caCertificates
                ];
                kafkaTools = [ pkgs.kcat ];
              in shellTools ++ binaryTools ++ dockerEnv ++ kafkaTools
              ++ networkTools ++ persistenceTools;

              pathsToLink = [ "/bin" "/etc" ];
            };
            config = {
              Entrypoint = [ "bash" ];
              User = "1069";
            };
          };
        };

        formatter = pkgs.nixfmt-rfc-style;
      });
}
