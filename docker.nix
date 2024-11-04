{ pkgs }:

pkgs.dockerTools.buildImage {
  name = "debug-container";
  tag = "latest";

  config = { Cmd = [ "bash" ]; };

  contents = pkgs.buildEnv {
    name = "debug-env";
    paths = with pkgs; [
      bash
      curl
      wget
      iproute2 # For 'ip' command and other networking tools.
      inetutils # For 'ping', 'traceroute', and other networking tools.
      netcat
      dnsutils # For 'dig' and 'nslookup'.
      htop
      strace
      lsof
      jq
      python3
      vim
      coreutils # For common Unix commands like 'cat', 'ls', etc.
      util-linux # Provides tools like 'lsblk', 'fdisk', 'more'.
      procps # For 'ps', 'top', etc.
      nmap
      tcpdump
      dstat
      zip
      unzip
    ];
  };
}
