(define-module (cyberdeck system services linux)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)

  #:use-module (gnu packages linux)

  #:use-module (guix gexp)

  #:export (acpid-configuration
            acpid-service-type))

(define-configuration/no-serialization acpid-configuration
  (acpid
   (file-like acpid)
   "acpid package to use"))

(define (acpid-shepherd-service config)
  "Return an <acpid-service> running acpid."
  (list
   (shepherd-service
    (provision '(acpid))
    (requirement '(root-file-system))

    (start #~(make-forkexec-constructor
              (list #$(file-append acpid) "/bin/acpid" " -f")))
    (stop #~(make-kill-destructor))
    (documentation "Run acpid"))))

(define acpid-service-type
  (service-type (name 'acpid)
                (extensions
                 (list (service-extension shepherd-root-service-type
                                          acpid-shepherd-service)))
                (description "Run acpid")))
