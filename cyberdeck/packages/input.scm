(define-module (cyberdeck packages input)
  #:use-module (guix build-system meson)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:))

(define-public iptsd
  (package
    (name "iptsd")
    (version "v0.5.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/linux-surface/iptsd/archive/refs/tags/"
                    version ".tar.gz"))
              (sha256
               (base32 "06jsib6d2hs4bx8ll4kph6rldk6qa1q05kkgvrm2zc37vrrwy33a"))))
    (build-system meson-build-system)
    (arguments
     `(#:configure-flags
       '("-Dservice_manager=none"
         "-Dsample_config=false")
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'remove-service-manager-req
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "meson_options.txt"
               (("'systemd', 'openrc'") "'systemd', 'openrc', 'none'"))
             #t)))))
    (inputs
     (list libinih))
    (native-inputs
     (list pkg-config))
    (home-page "https://github.com/linux-surface/iptsd")
    (synopsis "")
    (description "")
    (license license:gpl2)))
