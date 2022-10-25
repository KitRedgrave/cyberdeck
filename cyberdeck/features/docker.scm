(define-module (cyberdeck features docker)
  #:use-module (rde features)
  #:use-module (gnu packages docker)
  #:use-module (gnu services)
  #:use-module (gnu services docker)
  #:use-module (rde system services accounts)

  #:export (feature-docker))

(define* (feature-docker
          #:key
          (docker docker)
          (docker-cli docker-cli)
          (containerd containerd))
  "Configure docker and related packages."

  (define f-name 'docker)
  (define (get-system-services config)
    (list
     (simple-service
      'docker-add-docker-group-to-user
      rde-account-service-type
      (list "docker"))
     (service
      docker-service-type
      (docker-configuration
       (docker docker)
       (docker-cli docker-cli)
       (containerd containerd)))))

  (feature
   (name f-name)
   (values `((,f-name . #t)))
   (system-services-getter get-system-services)))
