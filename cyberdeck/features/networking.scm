(define-module (cyberdeck features networking)
  #:use-module (rde features)
  #:use-module (rde features predicates)

  #:use-module (guix gexp)

  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services networking)
  #:use-module (rde system services networking)
  #:use-module (cyberdeck system services networking)

  #:use-module (gnu packages networking)
  #:use-module (gnu packages gnome)
  #:use-module (cyberdeck packages networking)

  #:export (feature-networking
            feature-tailscale))

(define* (feature-networking
          #:key
          (iwd-autoconnect? #t)
          (network-manager-applet network-manager-applet))
  "Configure iwd and everything."
  (ensure-pred file-like? network-manager-applet)

  (define f-name 'networking)
  (define (get-home-services config)

    (list
     (simple-service 'network-manager-applet-package
                     home-profile-service-type
                     (list network-manager-applet))
     (simple-service
      'networking-nm-applet-shepherd-service
      home-shepherd-service-type
      (list
       (shepherd-service
        (provision '(nm-applet))
        (requirement '(dbus))
        (stop  #~(make-kill-destructor))
        (start #~(make-forkexec-constructor
                  (list #$(file-append network-manager-applet "/bin/nm-applet")
                        "--indicator")
                  #:log-file (string-append
                              (or (getenv "XDG_LOG_HOME")
                                  (format #f "~a/.local/var/log"
                                          (getenv "HOME")))
                              "/nm-applet.log"))))))))

  (define (get-system-services config)
    (list
     (service network-manager-service-type
              (network-manager-configuration (vpn-plugins
                                              (list network-manager-openvpn))))
     (service iwd-service-type
              (iwd-configuration
               (main-conf
                `((Settings ((AutoConnect . ,iwd-autoconnect?)))))))
     (service modem-manager-service-type)
     (service usb-modeswitch-service-type)
     (service wpa-supplicant-service-type)))

  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))


(define* (feature-tailscale
          #:key
          (tailscale tailscale))
  "Configure Tailscale"

  (define (get-system-services config)
    (list
     (service tailscale-service-type
              (tailscale-configuration))))

  (define (get-home-services config)
    (list
     (simple-service 'add-tailscale-to-profile
                     home-profile-service-type
                     (list tailscale))))

  (feature
   (name 'tailscale)
   (values `((tailscale . tailscale)))
   (system-services-getter get-system-services)
   (home-services-getter get-home-services)))
