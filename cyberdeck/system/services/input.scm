(define-module (cyberdeck system services input)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)

  #:use-module (cyberdeck packages input)
  #:use-module (guix gexp)

  #:export (iptsd-configuration
            iptsd-service-type))

(define-configuration/no-serialization iptsd-configuration
  (iptsd
   (file-like iptsd)
   "iptsd package to use"))

(define (iptsd-shepherd-service config)
  "Return an <iptsd-service> running iptsd"
  (list
   (shepherd-service
    (provision '(iptsd))
    (requirement '(root-file-system))

    (start #~(make-forkexec-constructor
              (list #$(file-append iptsd) "/bin/iptsd" " -f")))
    (stop #~(make-kill-destructor))
    (documentation "Run iptsd"))))

(define iptsd-service-type
  (service-type (name 'iptsd)
                (extensions
                 (list (service-extension shepherd-root-service-type
                                          iptsd-shepherd-service)))
                (description "Run iptsd")))
