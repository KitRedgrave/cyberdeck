(define-module (cyberdeck packages networking)
  #:use-module (guix build utils)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)

  #:use-module (gnu packages linux)
  #:use-module ((guix licenses) #:prefix license:))

(define-public tailscale
  (package
    (name "tailscale")
    (source
     (origin
       (method url-fetch/tarbomb)
       (uri "https://pkgs.tailscale.com/stable/tailscale_1.38.4_amd64.tgz")
       (sha256 (base32 "1wjiq7hzylv3dfkf835dwvq92ynm0afxcypiqb8n0ccbyr0wipli"))))
     (version "1.38.4")
     (build-system copy-build-system)
     (arguments
      '(#:install-plan
        '(("./tailscale_1.38.4_amd64/tailscale" "bin/")
          ("./tailscale_1.38.4_amd64/tailscaled" "bin/"))))
     (propagated-inputs
      (list iptables))
     (home-page "https://tailscale.com")
     (synopsis "The easiest, most secure way to use WireGuard and 2FA.")
     (description "The easiest, most secure way to use WireGuard and 2FA.")
     (license license:bsd-3)))
