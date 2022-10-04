(define-module (cyberdeck features flatpak)
  #:use-module (rde features)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu packages package-management)

  #:export (feature-flatpak))

(define* (feature-flatpak)
  "Setup and configure Flatpak."

  (define (flatpak-home-services config)
    "Returns home services related to Flatpak."
    (list
     (simple-service 'add-flatpak-to-profile
                     home-profile-service-type
                     (list flatpak))
     (simple-service 'add-flatpak-to-path
                     home-environment-variables-service-type
                     '(("XDG_DATA_DIRS" . "/home/alice/.local/share/flatpak/exports/share:$XDG_DATA_DIRS")))))

  (feature
   (name 'flatpak)
   (values '((flatpak . #t)))
   (home-services-getter flatpak-home-services)))
