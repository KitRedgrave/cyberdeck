(define-module (cyberdeck system services networking)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)

  #:use-module (cyberdeck packages networking)

  #:use-module (guix gexp)

  #:export (tailscale-configuration
            tailscale-service-type))

(define-configuration/no-serialization tailscale-configuration
  (tailscale
   (file-like tailscale)
   "tailscale package to use"))

(define (tailscale-shepherd-service config)
  "Return an <tailscale-service> running tailscaled."
  (list
   (shepherd-service
    (provision '(tailscale))
    (requirement '(root-file-system))

    (start #~(make-forkexec-constructor
              (list #$(file-append tailscale) "/bin/tailscaled")))
    (stop #~(make-kill-destructor))
    (documentation "Run tailscale"))))

(define tailscale-service-type
  (service-type (name 'tailscaled)
                (extensions
                 (list
                  (service-extension shepherd-root-service-type
                                     tailscale-shepherd-service)))
                (description "Run tailscale")))
