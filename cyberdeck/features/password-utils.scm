(define-module (cyberdeck features password-utils)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (gnu home-services password-utils)
  #:use-module (gnu home-services state)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu services)

  #:use-module (guix gexp)
  #:export (feature-password-store))

(define* (feature-password-store
          #:key
          (password-store password-store)
          (remote-password-store-url #f))
  "Setup and configure password manager."
  (ensure-pred file-like? password-store)

  (define (password-store-home-services config)
    "Returns home services related to password-store."
    (require-value 'gpg-primary-key config)
    (require-value 'home-directory config)
    (list (service home-password-store-service-type
                   (home-password-store-configuration
                    (package password-store)))
          (simple-service 'add-password-store-git-state
                          home-state-service-type
                          (list
                           (state-git
                            (string-append
                             (get-value 'home-directory config)
                             "/.local/var/lib/password-store")
                            remote-password-store-url)))))
  (feature
   (name 'password-store)
   (values `((pass . #t)
             (password-store . ,password-store)))
   (home-services-getter password-store-home-services)))
