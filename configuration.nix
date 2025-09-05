# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}:
let
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/networking.nix
    # ./modules/tuigreet.nix
  ];

# pretty ui
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ellie =
    # { pkgs, ... }:
    {
      home.packages = [
        # pkgs.atool
        # pkgs.httpie
      ];
      stylix = {
        iconTheme = {
          enable = true;
          dark = "BeautyLine";
          light = "BeautyLine";
          # gtk.iconTheme = {
          # enable = true;
          package = pkgs.beauty-line-icon-theme;
          # name = "BeautyLine";
          # };
        };
      };
      # programs.bash.enable = true;

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "24.11";
    };
  stylix = {
    enable = true;
    image = ./modules/wallpapers/gimptestpink.png;
    polarity = "dark";
    autoEnable = true;
    targets = {
      # gnome.enable = true;
      grub = {
        # enable = true;
        useImage = true;
      };
      gtk.enable = true;
    };
  };


# Virtualization and VM tools
programs.virt-manager.enable = true;
users.groups.libvirtd.members = [ "ellie" ];

virtualisation = {
  libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  spiceUSBRedirection.enable = true;
};

# vm testing

virtualisation.vmVariant = {
  virtualisation = {
    cores = 4;
    memorySize = 4096;        # in MB
    qemu.options = [
      "-enable-kvm"           # hardware acceleration
      "-vga virtio"           # accelerated graphics
      "-display sdl,gl=on"    # OpenGL acceleration
    ];
  };
};


# Nix features
nix.settings.experimental-features = [ "nix-command" "flakes" ];
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
nix.optimise.automatic = true;

# Firmware and graphics
xdg.portal.enable = true;
hardware = {
  enableRedistributableFirmware = true;
  graphics.enable= true;  
  nvidia = {
    modesetting.enable = true;         # Needed for Wayland compositors
    open = false;                      # Closed driver, not the open kernel module
    nvidiaSettings = true;             # Expose nvidia-settings GUI
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  bluetooth.enable = true;
  
};
services.pulseaudio.enable = false;
# X11/Wayland + DE
services.xserver = {
  enable = true;
  videoDrivers = [ "nvidia" ];
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
  xkb.layout = "us";
};
programs = {
  dconf.enable = true;
  xwayland.enable = true;
  fish.enable = true;
  bash.interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
  rog-control-center.enable = true;
  appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [ fusePackages.fuse_2 ];
    };
  };
  starship.enable = true;
  noisetorch.enable = true;
  adb.enable = true;
  openvpn3.enable = true;
};

# Bootloader & kernel
boot = {
  loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub.configurationLimit = 5;
  };
  kernelParams = [ "nouveau.modeset=0" ];
};

# Networking
networking.hostName = "nixos";
systemd.network.wait-online.enable = lib.mkForce false;
systemd.services.NetworkManager-wait-online.enable = false;

# Time & locale
time.timeZone = "America/New_York";
i18n = {
  defaultLocale = "en_US.UTF-8";
  extraLocaleSettings = let en = "en_US.UTF-8"; in {
    LC_ADDRESS = en; LC_IDENTIFICATION = en; LC_MEASUREMENT = en;
    LC_MONETARY = en; LC_NAME = en; LC_NUMERIC = en; LC_PAPER = en;
    LC_TELEPHONE = en; LC_TIME = en;
  };
};

# Extra system services
services = {
  sysprof.enable = true;
  hardware.openrgb = { package = pkgs.openrgb-with-all-plugins; enable = true; motherboard = "amd"; };
  fstrim = { enable = true; interval = "weekly"; };
  asusd = { enable = true; enableUserService = true; };
  mullvad-vpn.enable = true;
  flatpak.enable = true;
  printing.enable = true;
  pipewire = {
    enable = true;
    alsa = { enable = true; support32Bit = true; };
    pulse.enable = true;
  };
  supergfxd = {
    enable = true;
    settings = {
      always_reboot = false; no_logind = true; mode = "Integrated";
      vfio_enable = false; vfio_save = false;
      logout_timeout_s = 180; hotplug_type = "None";
    };
  };
};

# Misc system opts
security.rtkit.enable = true;
zramSwap.enable = true;

environment.sessionVariables = { QT_PLUGIN_PATH = ""; };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ellie = {
    isNormalUser = true;
    initialPassword = "ellie";
    description = "ellie";
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbusers"
      "kvm"
    ];
    packages = with pkgs; [
      firefox
      #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "ellie";

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = lib.mkDefault true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
