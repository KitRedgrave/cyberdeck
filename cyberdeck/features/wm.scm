(define-module (cyberdeck features wm)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)

  #:use-module (nongnu packages nvidia)

  #:use-module (rde features)

  #:export (feature-awesomewm))

(define* (feature-awesomewm
          #:key
          (awesome awesome))
  "Setup and configure awesome."

  (define (awesomewm-system-services config)
    (list
     (service slim-service-type
              (slim-configuration
               (xorg-configuration
                (xorg-configuration
                 (modules (list nvidia-driver
                                xf86-input-libinput))
                 (drivers '("nvidia" "modesetting"))
                 (keyboard-layout (get-value 'keyboard-layout config))
                 (extra-config
                  '(
                    "Section \"Monitor\"\n"
                    "  Identifier \"dp\"\n"
                    "  Modeline \"1620x1080\"  145.50  1624 1728 1896 2168  1080 1083 1093 1120 -hsync +vsync\n"
                    "  Option \"PreferredMode\" \"1620x1080\"\n"
                    "EndSection\n"
                    "Section \"Device\"\n"
                    "  Identifier \"device-nvidia\"\n"
                    "  Driver \"nvidia\"\n"
                    "  BusID \"PCI:2:0:0\"\n"
                    "  Option \"AllowExternalGpus\" \"True\"\n"
                    "  Option \"AllowEmptyInitialConfiguration\" \"True\"\n"
                    "EndSection\n"
                    "Section \"Screen\"\n"
                    "  Identifier \"intel\"\n"
                    "  Device \"device-modesetting\"\n"
                    "  Monitor \"dp\"\n"
                    "EndSection\n"
                    "Section \"Screen\"\n"
                    "  Identifier \"nvidia\"\n"
                    "  Device \"device-nvidia\"\n"
                    "  DefaultDepth 24\n"
                    "  Subsection \"Display\"\n"
                    "    Depth 24\n"
                    "  EndSubsection\n"
                    "  Option \"AllowEmptyInitialConfiguration\"\n"
                    "EndSection\n"
                    "Section \"InputClass\"\n"
                    "  Identifier \"input-touchpad\"\n"
                    "  Driver \"libinput\"\n"
                    "  MatchProduct \"Microsoft Surface Keyboard Touchpad\"\n"
                    "  Option \"Tapping\" \"on\"\n"
                    "EndSection\n"
                    "Section \"ServerLayout\"\n"
                    "  Identifier \"layout\"\n"
                    "  Screen 0 \"intel\"\n"
                    "EndSection\n"
                    ))))))
     (simple-service
      'add-awesomewm-packages
      profile-service-type
      (list
       awesome
       rofi
       rofi-pass))))
  (feature
   (name 'awesomewm)
   (values '((awesome . awesome)))
   (system-services-getter awesomewm-system-services)))
