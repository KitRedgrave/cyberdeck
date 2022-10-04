(define-module (cyberdeck features power)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services pm)

  #:export (feature-thermald
            feature-tlp))

(define* (feature-thermald
          #:key
          (thermald thermald)
          (adaptive? #f)
          (ignore-cpuid-check? #f))
  "Setup and configure thermald"
  (ensure-pred package? thermald)
  (ensure-pred boolean? adaptive?)
  (ensure-pred boolean? ignore-cpuid-check?)
  (define (thermald-system-services config)
    (list
     (service
      thermald-service-type
      (thermald-configuration
       (thermald thermald)
       (adaptive? adaptive?)
       (ignore-cpuid-check? ignore-cpuid-check?)))))

  (feature
   (name 'thermald)
   (values (make-feature-values thermald adaptive? ignore-cpuid-check?))
   (system-services-getter thermald-system-services)))

(define* (feature-tlp
          #:key
          (tlp tlp))
  "Setup and configure tlp"
  (ensure-pred package? tlp)
  (define (tlp-system-services config)
    (list
     (service
      tlp-service-type
      (tlp-configuration
       (cpu-scaling-governor-on-ac (list "performance"))
       (cpu-scaling-governor-on-bat (list "powersave"))
       (sched-powersave-on-bat? #t)))))

  (feature
   (name 'tlp)
   (values (make-feature-values tlp))
   (system-services-getter tlp-system-services)))
