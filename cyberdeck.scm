(define-module (cyberdeck)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages radio)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services linux)
  #:use-module (gnu services sddm)
  #:use-module (gnu services syncthing)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services vpn)
  #:use-module (gnu home services)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system mapped-devices)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (cyberdeck features arcan)
  #:use-module (cyberdeck features docker)
  #:use-module (cyberdeck features flatpak)
  #:use-module (cyberdeck features input)
  #:use-module (cyberdeck features networking)
  #:use-module (cyberdeck features password-utils)
  #:use-module (cyberdeck features power)
  #:use-module (cyberdeck features wm)
  #:use-module (cyberdeck packages linux)
  #:use-module (cyberdeck packages smalltalk)
  #:use-module (cyberdeck system services linux)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features fontutils)
  #:use-module (rde features gnupg)
  #:use-module (rde features keyboard)
  #:use-module (rde features linux)
  #:use-module (rde features security-token)
  #:use-module (rde features shells)
  #:use-module (rde features ssh)
  #:use-module (rde features system)
  #:use-module (rde features version-control)
  #:use-module (rde features xdg)
  #:use-module (ice-9 match))

(define*
  (pkgs #:rest lst)
  (map specification->package+output lst))

(define-public %alice-features
  (list
   (feature-user-info
    #:user-name "alice"
    #:full-name "Catherine Alice Redgrave"
    #:email "me@constructed.space"
    #:user-groups '("netdev" "audio" "video" "input" "wheel" "dialout" "kvm" "libvirt"))
   (feature-gnupg
    #:gpg-primary-key "D984D86CF8B7F35D"
    #:pinentry-flavor 'rofi)
   (feature-security-token)
   (feature-password-store
    #:remote-password-store-url "ssh://git@github.com/kitredgrave/password-store")
   (feature-keyboard
    #:keyboard-layout
    (keyboard-layout "us" "altgr-intl"
                     #:options
                     '("ctrl:nocaps"
                       "compose:ralt"
                       "terminate:ctrl_alt_bksp")))
   (feature-xdg)
   (feature-git)
   (feature-zsh
    #:default-shell? #t
    #:enable-zsh-autosuggestions? #t)))

(define kitbook-mapped-devices
  (list
   (mapped-device
    (source
     (uuid "4f419fb7-e82c-4a02-b792-0c9b494b0d27"))
    (target "cryptroot")
    (type luks-device-mapping))))

(define kitbook-file-systems
  (list
   (file-system
    (device
     (file-system-label "Guix"))
    (mount-point "/")
    (type "ext4")
    (dependencies kitbook-mapped-devices))
   (file-system
    (device
     (uuid "4682-7CA6" 'fat))
    (mount-point "/boot/efi")
    (type "vfat"))))

(define kithub-file-systems
  (list
   (file-system
     (mount-point "/boot/efi")
     (device
      (uuid "4F1D-961D" 'fat32))
     (type "vfat"))
   (file-system
     (mount-point "/")
     (device
      (uuid
       "6de8a30c-08c8-463b-a33d-fe08175f80a3" 'ext4))
     (type "ext4"))
   (file-system
     (mount-point "/home")
     (device
      (uuid
       "9d00e8c1-50a3-4080-9e58-2163d5efaf41" 'ext4))
     (type "ext4"))))

(define-public %kitbook-features
  (list
   (feature-host-info
    #:host-name "kitbook"
    #:timezone "America/Los_Angeles"
    #:locale "en_US.utf8")
   (feature-bootloader
    #:bootloader-configuration
    (bootloader-configuration
     (bootloader grub-efi-bootloader)
     (targets '("/boot/efi"))))
   (feature-kernel
    #:kernel linux-surface-6.1
    #:initrd microcode-initrd
    #:firmware
    (list linux-firmware)
    #:kernel-arguments
    '("modprobe.blacklist=pcspkr,nouveau"
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_DynamicPowerManagement=0x02"
      "i915.enable_fbc=0"
      "nowatchdog"))
   (feature-file-systems
    #:mapped-devices kitbook-mapped-devices
    #:file-systems   kitbook-file-systems
    #:swap-devices (list
                    (swap-space
                     (target "/swapfile")
                     (dependencies kitbook-mapped-devices))))
   (feature-hidpi)
   (feature-backlight)
   (feature-iptsd)
   (feature-thermald
    #:adaptive? #t)))

(define-public %kithub-features
  (list
    (feature-host-info
     #:host-name "kithub"
     #:timezone "America/Los_Angeles"
     #:locale "en_US.utf8")
    (feature-bootloader
     #:bootloader-configuration
     (bootloader-configuration
       (bootloader grub-efi-bootloader)
       (targets '("/boot/efi"))))
    (feature-kernel
     #:kernel linux
     #:initrd microcode-initrd
     #:firmware (list linux-firmware)
     #:kernel-arguments
     '("modprobe.blacklist=dvb_usb_rtl28xxu"))
    (feature-file-systems
     #:file-systems kithub-file-systems)))

(define-public %workstation-features
  (list
   (feature-fonts
    #:font-monospace
    (font "Source Code Pro")
    #:font-sans
    (font "Source Sans 3")
    #:font-serif
    (font "Source Serif")
    #:font-packages
    (pkgs "font-awesome"
          "font-google-material-design-icons"
          "font-openmoji"
          "font-mathjax"
          "font-adobe-source-code-pro"
          "font-adobe-source-serif-pro"
          "font-adobe-source-sans-pro"
          "font-adobe-source-han-sans"
          "font-adobe-source-han-sans:cn"
          "font-adobe-source-han-sans:jp"
          "font-adobe-source-han-sans:kr"
          "font-adobe-source-han-sans:tw"))
   (feature-base-packages
    #:base-home-packages
    (list nss-certs))
   (feature-base-services
    #:guix-substitute-urls
    (list "https://substitutes.nonguix.org")
    #:guix-authorized-keys
    (list
     (local-file "nongnu-signing-key.pub")))
   (feature-custom-services
    #:system-services
    (list (service acpid-service-type
                   (acpid-configuration
                    (acpid acpid)))
          (service earlyoom-service-type)
          (udev-rules-service 'rtl-sdr rtl-sdr)
          (service libvirt-service-type
                   (libvirt-configuration
                    (auth-unix-ro "none")
                    (auth-unix-rw "none")))
          (service sddm-service-type)))
   (feature-networking)
   (feature-ssh)
   (feature-desktop-services)
   (feature-pipewire
    #:pipewire pipewire)
   (feature-awesomewm)
   (feature-i3)
   (feature-arcan)
   (feature-flatpak)
   (feature-docker)
   (feature-tailscale)))

(define-public kitbook-config
  (rde-config
   (integrate-he-in-os? #t)
   (features
    (append
     %kitbook-features
     %workstation-features
     %alice-features))
   ;; XXX: can't use custom system service feature for sysctl, since it can't redefine these settings
   ;; instead we have to do recursive brain surgery, sigh
   (system-services
    (modify-services ((@@ (rde features) fold-system-services)
                      (rde-config-features kitbook-config)
                      kitbook-config)
      ;; sysctl settings tuned for latency, stolen from cfs-zen-tweaks
      (sysctl-service-type config =>
                           (sysctl-configuration
                            (settings
                             (append '(("vm.compaction_proactiveness" . "0")
                                       ("vm.compact_unevictable_allowed" . "0")
                                       ("vm.min_free_kbytes" . "786432")
                                       ("vm.swappiness" . "0")
                                       ("vm.zone_reclaim_mode" . "0")
                                       ("kernel.mm.transparent_hugepage.enabled" . "never")
                                       ("kernel.mm.transparent_hugepage.shmem_enabled" . "never")
                                       ("kernel.mm.transparent_hugepage.khugepaged.defrag" . "0")
                                       ("vm.page_lock_unfairness" . "1")
                                       ("kernel.sched_child_runs_first" . "0")
                                       ("kernel.sched_autogroup_enabled" . "1")
                                       ("kernel.sched_cfs_bandwidth_slice_us" . "500")
                                       ("kernel.debug.sched.latency_ns" . "1000000")
                                       ("kernel.debug.sched.migration_cost_ns" . "500000")
                                       ("kernel.debug.sched.min_granularity_ns" . "0")
                                       ("kernel.debug.sched.wakeup_granularity.ns" . "0")
                                       ("kernel.debug.sched.nr_migrate" . "8"))
                                     %default-sysctl-settings))))))))

(define-public kithub-config
  (rde-config
   (integrate-he-in-os? #t)
    (features
      (append
       %kithub-features
       %workstation-features
       %alice-features))
   ;; XXX: can't use custom system service feature for sysctl, since it can't redefine these settings
   ;; instead we have to do recursive brain surgery, sigh
   (system-services
    (modify-services ((@@ (rde features) fold-system-services)
                      (rde-config-features kithub-config)
                      kithub-config)
      ;; sysctl settings tuned for latency, stolen from cfs-zen-tweaks
      (sysctl-service-type config =>
                           (sysctl-configuration
                            (settings
                             (append '(("vm.compaction_proactiveness" . "0")
                                       ("vm.compact_unevictable_allowed" . "0")
                                       ("vm.min_free_kbytes" . "786432")
                                       ("vm.swappiness" . "0")
                                       ("vm.zone_reclaim_mode" . "0")
                                       ("kernel.mm.transparent_hugepage.enabled" . "never")
                                       ("kernel.mm.transparent_hugepage.shmem_enabled" . "never")
                                       ("kernel.mm.transparent_hugepage.khugepaged.defrag" . "0")
                                       ("vm.page_lock_unfairness" . "1")
                                       ("kernel.sched_child_runs_first" . "0")
                                       ("kernel.sched_autogroup_enabled" . "1")
                                       ("kernel.sched_cfs_bandwidth_slice_us" . "500")
                                       ("kernel.debug.sched.latency_ns" . "1000000")
                                       ("kernel.debug.sched.migration_cost_ns" . "500000")
                                       ("kernel.debug.sched.min_granularity_ns" . "0")
                                       ("kernel.debug.sched.wakeup_granularity.ns" . "0")
                                       ("kernel.debug.sched.nr_migrate" . "8"))
                                     %default-sysctl-settings))))))))

(define-public kitbook-system
  (rde-config-operating-system kitbook-config))

(define-public kitbook-home
  (rde-config-home-environment kitbook-config))

(define-public kithub-system
  (rde-config-operating-system kithub-config))

(define-public kithub-home
  (rde-config-home-environment kithub-config))

(define
  (dispatcher)
  (let
      ((rde-target
        (getenv "RDE_TARGET")))
    (match rde-target
      ("kitbook-home" kitbook-home)
      ("kitbook-system" kitbook-system)
      ("kithub-home" kithub-home)
      ("kithub-system" kithub-system)
      (_ kitbook-home))))

(dispatcher)
