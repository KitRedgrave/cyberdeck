(define-module (cyberdeck features wm)
  #:use-module (gnu packages compton)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sddm)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system pam)
  #:use-module (rde home services wm)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)

  #:export (feature-awesomewm
            feature-i3))

(define* (feature-i3
          #:key
          (i3 i3-wm))
  "Setup and configure i3"

  (define (i3-system-services config)
    (list
     (simple-service
      'add-i3-packages
      profile-service-type
      (list
       i3-wm
       rofi
       rofi-pass
       polybar
       picom))))

  (feature
   (name 'i3)
   (values '((i3 . i3)))
   (system-services-getter i3-system-services)))

(define* (feature-awesomewm
          #:key
          (awesome awesome))
  "Setup and configure awesome."

  (define (awesomewm-system-services config)
    (list
     (simple-service
      'add-awesomewm-packages
      profile-service-type
      (list
       awesome
       rofi
       rofi-pass
       arc-icon-theme
       xscreensaver))))

  (feature
   (name 'awesomewm)
   (values '((awesome . awesome)))
   (system-services-getter awesomewm-system-services)))

