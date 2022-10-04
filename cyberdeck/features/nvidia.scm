(define-module (cyberdeck features nvidia)
  #:use-module (guix packages)
  #:use-module (nongnu packages nvidia)
  #:use-module (rde features)

  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services linux)
  #:use-module (gnu services xorg)

  #:export (feature-nvidia))

(define* (feature-nvidia)
  "Setup and configure nVidia drivers."

  (define (nvidia-system-services config)
    "Returns system services related to nVidia drivers."
    (list
     (service kernel-module-loader-service-type
              '("ipmi_devintf"
                "nvidia"
                "nvidia_drm"
                "nvidia_modeset"
                "nvidia_uvm"))
     (simple-service 'nvidia-udev-rules
                     udev-service-type
                     (list nvidia-driver))
     (set-xorg-configuration ("Section \"Device\"\n"
                              "  Identifier \"dgpu\"\n"
                              "  Driver \"nvidia\"\n"
                              "  BusID \"PCI:2:0:0\"\n"
                              "  Option \"AllowExternalGpus\" \"True\"\n"
                              "  Option \"ConnectToAcpid\" \"False\"\n"
                              "  Option \"AllowEmptyInitialConfiguration\" \"True\"\n"
                              "EndSection\n"
                              "Section \"Device\"\n"
                              "  Identifier \"igpu\"\n"
                              "  Driver \"modesetting\"\n"
                              "  BusID \"PCI:0:2:0\"\n"
                              "EndSection\n"
                              "Section \"Screen\"\n"
                              "  Identifier \"igpu\"\n"
                              "  Device \"igpu\"\n"
                              "  DefaultDepth 24\n"
                              "  Subsection \"Display\"\n"
                              "    Depth 24\n"
                              "  EndSubsection\n"
                              "EndSection\n"
                              "Section \"Screen\"\n"
                              "  Identifier \"dgpu\"\n"
                              "  Device \"dgpu\"\n"
                              "EndSection\n"
                              "Section \"ServerLayout\"\n"
                              "  Identifier \"layout\"\n"
                              "  Screen 0 \"igpu\"\n"
                              "  Inactive \"dgpu\"\n"
                              "  Option \"AllowNVIDIAGPUScreens\"\n"
                              "EndSection\n"))))

  (feature
   (name 'nvidia)
   (system-services-getter nvidia-system-services)))
