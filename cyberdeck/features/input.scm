(define-module (cyberdeck features input)
  #:use-module (gnu services)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (cyberdeck system services input)
  #:use-module (cyberdeck packages input)

  #:export (feature-iptsd))
(define* (feature-iptsd
          #:key
          (iptsd iptsd))
  "Configure iptsd"
  (ensure-pred package? iptsd)

  (define (get-system-services config)
    (list
     (service
      iptsd-service-type
      (iptsd-configuration
       (iptsd iptsd)))))

  (feature
   (name 'iptsd)
   (values `((iptsd . iptsd)))
   (system-services-getter get-system-services)))
