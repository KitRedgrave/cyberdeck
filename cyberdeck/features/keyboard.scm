(define-module (cyberdeck features keyboard)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (gnu system keyboard)
  #:use-module (gnu services)
  #:use-module (cyberdeck home services keyboard)

  #:export (feature-keyboard))

(define* (feature-keyboard #:key keyboard-layout)
  "Sets keyboard layout.  Affects bootloader, and XKB_* variables for the user."
  (ensure-pred keyboard-layout? keyboard-layout)
  (define (keyboard-services values)
    "Returns home-keyboard service."
    (list
     (service home-keyboard-service-type keyboard-layout)))

  (feature
   (name 'keyboard)
   (values (make-feature-values keyboard-layout))
   (home-services-getter keyboard-services)))
