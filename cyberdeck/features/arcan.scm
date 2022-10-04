(define-module (cyberdeck features arcan)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (rde system services accounts)
  #:use-module (cyberdeck packages arcan)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix packages)

  #:export (feature-arcan))

(define* (feature-arcan
          #:key
          (arcan arcan))
  "Setup and configure arcan."
  (ensure-pred any-package? arcan)

  (define (arcan-system-services config)
    "Returns system services related to arcan."
    (list
     (simple-service 'arcan-groups
                     rde-account-service-type
                     (list "input"))))

  (define (arcan-home-services config)
    "Returns home services related to arcan."
    (list
     (simple-service 'arcan-packages
                     home-profile-service-type
                     (list arcan
                           xarcan))
     (simple-service 'arcan-env-vars
                     home-environment-variables-service-type
                     `(("ARCAN_RESOURCEPATH" . ,(file-append arcan "/share/arcan/resources"))
                       ("ARCAN_SCRIPTPATH" . ,(file-append arcan "/share/arcan/scripts"))
                       ("ARCAN_APPLTEMPPATH" . "$HOME/.cache/arcan")
                       ("ARCAN_APPLSTOREPATH" . "$HOME/.cache/arcan")
                       ("ARCAN_STATEBASEPATH" . "$HOME/.arcan/resources/savestates")
                       ("ARCAN_BINPATH" . ,(file-append arcan "/bin/arcan_frameserver"))))))
  (feature
   (name 'arcan)
   (values (make-feature-values arcan))
   (home-services-getter arcan-home-services)
   (system-services-getter arcan-system-services)))
