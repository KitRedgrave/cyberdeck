(define-module (cyberdeck packages smalltalk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages autotools))

(define-public pharo-vm
  (package
    (name "pharo-vm")
    (version "v10.0.3")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/KitRedgrave/pharo-vm")
         (commit "fix/cairo-cmake")))
       (sha256
        (base32 "0v3fhng1jd8by3w69hslma430s07qd3g1p6ak2fkqw4njy9rgv13"))))
    (build-system cmake-build-system)
    (arguments
     '(#:configure-flags '("-DBUILD_BUNDLE=off"
                           "-DBUILD_WITH_GRAPHVIZ=off"
                           "-DBUILD_IS_RELEASE=on"
                           "-DGENERATE_VMMAKER=off"
                           "-DGENERATE_SOURCES=off")))
    (native-inputs
     (list pkg-config))
    (inputs
     (list freetype
           libgit2
           unzip
           wget
           sdl2
           libffi
           openssl
           cairo
           pixman
           libpng
           `(,util-linux "lib")))
    (synopsis "Pharo VM")
    (description "Pharo VM")
    (home-page "https://pharo.org")
    (license license:expat)))
