{ config, pkgs, ... }:

{
  imports = [
    ../linux-common-amd.nix
    ../linux-desktop-common.nix
    ../nvidia.nix
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  powerManagement.cpuFreqGovernor = "schedutil";

  networking.hostName = "stormveil";

  time.timeZone = "America/New_York";

  sops.secrets.stormveil-wireguard-privkey = {
    sopsFile = ../../secrets/stormveil/wireguard.yaml;
  };
  networking = {
    useDHCP = false;

    networkmanager = {
      enable = false;
      unmanaged = [ "enp34s0" "enp37s0" "enp37s0d1" ];
    };

    bridges.br0 = { interfaces = [ "enp37s0" "enp37s0d1" ]; };

    interfaces = {
      enp34s0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.169.20";
          prefixLength = 24;
        }];
      };
      br0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "10.10.31.20";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = "192.168.169.1";
    nameservers = [ "192.168.169.1" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  sops.secrets.stormveil-kenzie-password = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
    neededForUsers = true;
  };
  users = {
    mutableUsers = false;

    users.kenzie = {
      createHome = true;
      extraGroups = [ "docker" "wheel" ];
      home = "/home/kenzie";
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      passwordFile = "${config.sops.secrets.stormveil-kenzie-password.path}";
      shell = pkgs.zsh;
    };

    users.root = {
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      password = null;
      shell = pkgs.zsh;
    };
  };

  sops.secrets.common-gpg-keyring = {
    mode = "0040";
    group = "wheel";
    sopsFile = ../../secrets/common/common.yaml;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    users.kenzie = import ../../home/home-linux-desktop.nix;
    users.root = import ../../home/home-linux-server.nix;
  };

  hardware.firmware = with pkgs; [ broadcom-bt-firmware ];
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  services.openssh.enable = true;

  networking.firewall.enable = false;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  systemd.enableUnifiedCgroupHierarchy = false;

  sops.secrets.stormveil-restic-password = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
  };
  sops.secrets.stormveil-restic-b2-environment = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
  };
  sops.secrets.stormveil-restic-b2-password = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
  };
  sops.secrets.stormveil-restic-ainsel-s3-environment = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
  };
  sops.secrets.stormveil-restic-ainsel-s3-password = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
  };
  services.restic.backups = let
    localBackupExcludePaths = [
      ''--exclude="/var/cache"''
      ''--exclude="/home/kenzie/.config/Element/Cache"''
      ''--exclude="/home/kenzie/.cache"''
    ];
    remoteBackupExcludePaths = [
      ''--exclude="/home/kenzie/.local/share/containers"''
      ''--exclude="/home/kenzie/.local/share/Steam"''
      ''--exclude="/home/kenzie/.config/Element/Cache"''
      ''--exclude="/home/kenzie/.var/app/com.valvesoftware.Steam"''
      ''--exclude="/home/kenzie/.cache"''
      ''--exclude="/home/kenzie/Downloads"''
    ];
  in {
    lanBackup = {
      initialize = true;
      passwordFile = "${config.sops.secrets.stormveil-restic-password.path}";
      paths = [ "/home" "/root" "/mnt/linux-game-libraries" ];
      pruneOpts = [
        "--keep-daily 30"
        "--keep-weekly 12"
        "--keep-monthly 36"
        "--keep-yearly 100"
      ];
      extraBackupArgs = [ "--compression=auto" ] ++ localBackupExcludePaths;
      extraOptions = [ "verbose=1" ];
      repository =
        "sftp:restic@10.10.31.10:/hangar/restic-backups/stormveil-backups";
      timerConfig = { OnCalendar = "daily"; };
    };
    b2Backup = {
      environmentFile =
        "${config.sops.secrets.stormveil-restic-b2-environment.path}";
      initialize = true;
      passwordFile = "${config.sops.secrets.stormveil-restic-b2-password.path}";
      paths = [ "/home" "/root" ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      extraBackupArgs = [ "--compression=auto" ] ++ remoteBackupExcludePaths;
      extraOptions = [ "verbose=1" ];
      repository = "b2:restic-stormveil:/";
      timerConfig = { OnCalendar = "daily"; };
    };
    ainselBackup = {
      environmentFile =
        "${config.sops.secrets.stormveil-restic-ainsel-s3-environment.path}";
      initialize = true;
      passwordFile =
        "${config.sops.secrets.stormveil-restic-ainsel-s3-password.path}";
      paths = [ "/home" "/root" ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      extraBackupArgs = [ "--compression=auto" ] ++ remoteBackupExcludePaths;
      extraOptions = [ "verbose=1" ];
      repository = "s3:https://s3.ainsel.kenzi.dev/stormveil-backups";
      timerConfig = { OnCalendar = "daily"; };
    };
  };

  services.openiscsi.enable = true;
  services.openiscsi.name = "iqn.2016-04.com.open-iscsi:c0ee13f5fb49";

  # TODO: find a better way to do this
  systemd.services."stormveil-iscsi-mount" = {
    wantedBy = [ "remote-fs.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.umount}/bin/umount /mnt/linux-game-libraries || true
      ${pkgs.openiscsi}/bin/iscsiadm -m node -U all || true # Log out of all existing sessions first, ignore the result because this will fail on a fresh reboot
      ${pkgs.openiscsi}/bin/iscsiadm -m discovery -t sendtargets -l -p 10.10.31.10:3260
      sleep 3 # Horrible hack because iscsiadm exits before the device has finished attaching
      ${pkgs.mount}/bin/mount -t xfs -o _netdev,discard /dev/disk/by-uuid/2e1225e2-9e91-4461-af01-6c229086bda5 /mnt/linux-game-libraries
    '';
  };

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    (callPackage ../../pkgs/sunshine/default.nix { })
    virt-manager
    wine-staging
  ];

  hardware.opengl.driSupport32Bit = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
