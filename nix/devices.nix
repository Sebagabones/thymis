args@{ ... }:
let
  inherit (args) inputs lib pkgs;
  deviceConfig = {
    generic-x86_64 = { ... }: { nixpkgs.hostPlatform = "x86_64-linux"; };
    generic-aarch64 = { ... }: { nixpkgs.hostPlatform = "aarch64-linux"; };
    raspberry-pi-3 = { modulesPath, ... }: {
      disabledModules =
        [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
      imports = [ inputs.raspberry-pi-nix.nixosModules.raspberry-pi ];
      systemd.watchdog.runtimeTime = "15s";
      raspberry-pi-nix.libcamera-overlay.enable = false;
      raspberry-pi-nix.board = "bcm2711";
      hardware.raspberry-pi.config = {
        all = { base-dt-params = { audio = { enable = true; }; }; };
      };
      boot.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
      boot.kernel.sysctl."vm.mmap_rnd_bits" = 24;
      nixpkgs.overlays = [
        (final: prev: {
          makeModulesClosure = x:
            prev.makeModulesClosure (x // { allowMissing = true; });
          compressFirmwareXz =
            inputs.nixpkgs.legacyPackages.${final.stdenv.system}.compressFirmwareXz;
          compressFirmwareZstd =
            inputs.nixpkgs.legacyPackages.${final.stdenv.system}.compressFirmwareZstd;
          raspberrypiWirelessFirmware = prev.raspberrypiWirelessFirmware // {
            compressFirmware = false;
          };
        })
      ];
      nixpkgs.hostPlatform = "aarch64-linux";
    };
    raspberry-pi-4 = { modulesPath, ... }: {
      disabledModules =
        [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
      imports = [ inputs.raspberry-pi-nix.nixosModules.raspberry-pi ];
      systemd.watchdog.runtimeTime = "15s";
      raspberry-pi-nix.libcamera-overlay.enable = false;
      raspberry-pi-nix.board = "bcm2711";
      boot.kernelParams = [
        "snd_bcm2835.enable_headphones=1"
        "snd_bcm2835.enable_hdmi=1"
        "brcmfmac.roamoff=1"
        "brcmfmac.feature_disable=0x282000"
      ];
      boot.kernel.sysctl."vm.mmap_rnd_bits" = 24;
      hardware.raspberry-pi.config = {
        all = {
          dt-overlays = {
            vc4-fkms-v3d = {
              enable = true;
              params = { };
            };
          };
        };
      };
      nixpkgs.overlays = lib.mkAfter [
        (final: prev: {
          makeModulesClosure = x:
            prev.makeModulesClosure (x // { allowMissing = true; });
          compressFirmwareXz =
            inputs.nixpkgs.legacyPackages.${final.stdenv.system}.compressFirmwareXz;
          compressFirmwareZstd =
            inputs.nixpkgs.legacyPackages.${final.stdenv.system}.compressFirmwareZstd;
          raspberrypiWirelessFirmware = prev.raspberrypiWirelessFirmware // {
            compressFirmware = false;
          };
        })
      ];
      nixpkgs.hostPlatform = "aarch64-linux";
    };
    raspberry-pi-5 = { pkgs, modulesPath, ... }: {
      disabledModules =
        [ "${modulesPath}/installer/sd-card/sd-image-aarch64.nix" ];
      # imports = [ inputs.raspberry-pi-nix.nixosModules.raspberry-pi ];
      imports = [
        # Hardware configuration
        inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
        inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
        inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
        inputs.nixos-raspberrypi.nixosModules.trusted-nix-caches
      ];
      systemd.watchdog.runtimeTime = "15s";
      # raspberry-pi-nix.libcamera-overlay.enable = false;
      # raspberry-pi-nix.board = "bcm2712";
      boot.kernel.sysctl."vm.mmap_rnd_bits" = 24;
      nixpkgs.overlays = [
        (final: prev: {
          makeModulesClosure = x:
            prev.makeModulesClosure (x // { allowMissing = true; });
          compressFirmwareXz =
            inputs.nixpkgs.legacyPackages.${final.stdenv.system}.compressFirmwareXz;
          compressFirmwareZstd =
            inputs.nixpkgs.legacyPackages.${final.stdenv.system}.compressFirmwareZstd;
          raspberrypiWirelessFirmware = prev.raspberrypiWirelessFirmware // {
            compressFirmware = false;
          };
        })
      ];
      nixpkgs.hostPlatform = "aarch64-linux";
      hardware.raspberry-pi.config = {
        config = {
          all = {
            options = {

              # Automatically load overlays for detected cameras
              camera_auto_detect = {
                enable = lib.mkDefault true;
                value = lib.mkDefault true;
              };

              # Automatically load overlays for detected DSI displays
              display_auto_detect = {
                enable = lib.mkDefault true;
                value = lib.mkDefault true;
              };

              # Automatically load initramfs files, if found
              auto_initramfs = {
                enable = true;
                value = 1;
              };

              # For DRM VC4 V3D driver (vc4-kms-v3d) below
              max_framebuffers = {
                enable = lib.mkDefault true;
                value = lib.mkDefault 2;
              };

              # Don't have the firmware create an initial video= setting in cmdline.txt.
              # Use the kernel's default instead.
              disable_fw_kms_setup = {
                enable = lib.mkDefault true;
                value = lib.mkDefault true;
              };
              # Run in 64-bit mode
              arm_64bit = {
                enable = lib.mkDefault true;
                value = lib.mkDefault true;
              };

              # Disable compensation for displays with overscan
              disable_overscan = {
                enable = lib.mkDefault true;
                value = lib.mkDefault true;
              };

              # Run as fast as firmware / board allows
              arm_boost = {
                enable = lib.mkDefault true;
                value = lib.mkDefault true;
              };
            };
            base-dt-params = {
              # Uncomment some or all of these to enable the optional hardware interfaces
              i2c_arm = {
                enable = true;
                value = "on";
              };
              i2s = {
                enable = true;
                value = "on";
              };
              spi = {
                enable = true;
                value = "on";
              };

              # Enable audio (loads snd_bcm2835)
              audio = {
                enable = true;
                value = "on";
              };
            };
            dt-overlays = {
              # Enable DRM VC4 V3D driver
              vc4-kms-v3d = {
                enable = lib.mkDefault true;
                params = { };
              };

            };
          };
        };
        extra-config = ''
          dtoverlay=ov5647
          dtoverlay=vc4-kms-dsi-waveshare-panel,10_1_inch,dsi0
        '';
      };
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.mesa.drivers ];
      };
      services.xserver.extraConfig = ''
        Section "OutputClass"
          Identifier "vc4"
          MatchDriver "vc4"
          Driver "modesetting"
          Option "PrimaryGPU" "true"
        EndSection
      '';
    };
  };
in deviceConfig
