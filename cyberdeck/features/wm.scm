(define-module (cyberdeck features wm)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)

  #:use-module (rde features)

  #:export (feature-awesomewm))

(define* (feature-awesomewm
          #:key
          (awesome awesome))
  "Setup and configure awesome."

  (define (awesomewm-system-services config)
    (list
     (service gdm-service-type)
     (simple-service
      'add-awesomewm-packages
      profile-service-type
      (list
       awesome
       rofi
       rofi-pass
       arc-icon-theme))))
  (feature
   (name 'awesomewm)
   (values '((awesome . awesome)))
   (system-services-getter awesomewm-system-services)))
