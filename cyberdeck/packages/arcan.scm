(define-module (cyberdeck packages arcan)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system meson)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) :prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages apr)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages onc-rpc)
  #:use-module (gnu packages ocr)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages selinux)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vnc)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg))

(define-public arcan
  (let ((commit "78229edbe3e9fe943ae13b9e284fdddb64317efb")
        (revision "1"))
    (package
      (name "arcan")
      (version (git-version "master" revision commit))
      (source (origin
                (method git-fetch)
                (file-name (git-file-name name version))
                (uri (git-reference
                      (url "https://github.com/letoram/arcan")
                      (commit commit)))
                (sha256
                 (base32 "0jm8jw5k48qczd9rpr9gi5l2z04lhxp9cxnv29pa7ypf69vjlgkz"))))
      (build-system cmake-build-system)
      (arguments
       `(#:configure-flags '("-DCMAKE_C_FLAGS=-fcommon"
                             "-DVIDEO_PLATFORM=egl-dri"
                             "-DBUILTIN_LUA=off"
                             "-DSTATIC_OPENAL=off"
                             "-DSTATIC_SQLITE3=off"
                             "-DSTATIC_FREETYPE=off"
                             "-DHYBRID_SDL=on"
                             "-DHYBRID_HEADLESS=on"
                             "-DSHMIF_TUI_ACCEL=on")
         #:phases
         (modify-phases %standard-phases
           (add-after 'unpack 'fix-cmake-paths
             (lambda* (#:key inputs #:allow-other-keys)
               (substitute* "src/platform/cmake/modules/FindAPR.cmake"
                 (("/usr/local/apr/include/apr-1")
                  (search-input-directory inputs "include/apr-1")))
               #t))
           ;; Normally, it tries to fetch patched openal with git
           ;; but copying files manually in the right place seems to work too.
           (add-after 'unpack 'prepare-static-openal
             (lambda* (#:key inputs #:allow-other-keys)
               (let ((arcan-openal (assoc-ref inputs "arcan-openal")))
                 (copy-recursively arcan-openal "external/git/openal"))
               #t))
           (add-after 'prepare-static-openal 'generate-man
             (lambda _
               (with-directory-excursion "doc"
                 (invoke "ruby" "docgen.rb" "mangen"))
               #t))
           (add-before 'configure 'chdir
             (lambda _
               (chdir "src")
               #t))
           (add-after 'install 'wrap-program
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((out (assoc-ref outputs "out")))
                 (wrap-program (string-append out "/bin/arcan")
                   `("ARCAN_RESOURCEPATH" ":" suffix
                     (,(string-append out "/share/arcan/resources")))
                   `("ARCAN_SCRIPTPATH" ":" =
                     (,(string-append out "/share/arcan/scripts")))
                   `("ARCAN_APPLTEMPPATH" ":" =
                     ("$HOME/.cache/arcan"))
                   `("ARCAN_APPLBASEPATH" ":" =
                     (,(string-append out "/share/arcan/appl")))
                   `("ARCAN_APPLSTOREPATH" ":" =
                     ("$HOME/.cache/arcan"))
                   `("ARCAN_STATEBASEPATH" ":" =
                     ("$HOME/.arcan/resources/savestates"))
                   `("ARCAN_BINPATH" ":" =
                     (,(string-append out "/bin/arcan_frameserver")))))
               #t)))
         #:tests? #f))
      (native-search-paths
       (list (search-path-specification
              (variable "ARCAN_APPLBASEPATH")
              (separator #f)
              (files '("share/arcan/appl")))
             (search-path-specification
              (variable "ARCAN_SCRIPTPATH")
              (separator #f)
              (files '("share/arcan/scripts")))))
      (inputs
       `(("apr" ,apr)
         ("bash-minimal" ,bash-minimal)
         ("ffmpeg" ,ffmpeg)
         ("freetype" ,freetype)
         ("glib" ,glib)
         ("glu" ,glu)
         ("harfbuzz" ,harfbuzz)
         ("libdrm" ,libdrm)
         ("libusb" ,libusb)
         ("libvnc" ,libvnc)
         ("libxcb" ,libxcb)
         ("libxkbcommon" ,libxkbcommon)
         ("luajit" ,luajit)
         ("lzip" ,lzip)
         ("openal" ,openal)
         ("mesa" ,mesa)
         ("pcre" ,pcre)
         ("sdl2" ,sdl2)
         ("sqlite" ,sqlite)
         ("tesseract-ocr" ,tesseract-ocr)
         ("leptonica" ,leptonica)
         ("vlc" ,vlc)
         ("xcb-util" ,xcb-util)
         ("xcb-util-wm" ,xcb-util-wm)
         ("wayland" ,wayland)
         ("wayland-protocols" ,wayland-protocols)
         ;;  To build arcan_lwa, we need a patched version of openal.
         ;; https://github.com/letoram/arcan/wiki/packaging
         ("arcan-openal" ,(origin
                            (method git-fetch)
                            (file-name "arcan-openal-0.5.4")
                            (uri (git-reference
                                  (url "https://github.com/letoram/openal")
                                  (commit "1c7302c580964fee9ee9e1d89ff56d24f934bdef")))
                            (sha256
                             (base32
                              "0dcxcnqjkyyqdr2yk84mprvkncy5g172kfs6vc4zrkklsbkr8yi2"))))))
      (native-inputs
       (list pkg-config ruby))               ; For documentation and testing
      (home-page "https://arcan-fe.com")
      (synopsis "Display server, multimedia framework and game engine (egl-dri)")
      (description "Arcan is a development framework for creating virtually
anything from user interfaces for specialized embedded applications
all the way to full-blown desktop environments.  At its heart lies a multimedia
engine programmable using Lua.")
      ;; https://github.com/letoram/arcan/blob/master/COPYING
      (license (list license:gpl2+
                     license:lgpl2.0
                     license:lgpl2.0+
                     license:public-domain
                     license:bsd-3)))))

(define-public xarcan
  (let
    ((commit "02111f4925453c0c545e9193c6a5e22c0d4e98c3")
     (revision "1"))
    (package
      (name "xarcan")
      (version (git-version "master" revision commit))
      (source
       (origin (method git-fetch)
               (file-name (git-file-name name version))
               (uri (git-reference
                     (url "https://github.com/letoram/xarcan")
                     (commit commit)))
               (sha256
                (base32 "06c8gcvm0rprdsm7bjbfir0wcx5zzz5px69agxfydl7g2qssr7df"))))
    (build-system meson-build-system)
    (arguments
    `(#:configure-flags '("-Dxwayland=true")
      #:tests? #f))
    (inputs
     `(("arcan" ,arcan)
       ("fontutil" ,font-util)
       ("libdrm" ,libdrm)
       ("libepoxy" ,libepoxy)
       ("libgcrypt" ,libgcrypt)
       ("libtirpc" ,libtirpc)
       ("libselinux" ,libselinux)
       ("libxcvt" ,libxcvt)
       ("libxfont2" ,libxfont2)
       ("libxkbfile" ,libxkbfile)
       ("libxext" ,libxext)
       ("pixman" ,pixman)
       ("xcb-util" ,xcb-util)
       ("xcb-util-wm" ,xcb-util-wm)
       ("xtrans" ,xtrans)
       ("wayland" ,wayland)
       ("wayland-protocols" ,wayland-protocols)))
    (native-inputs
     (list pkg-config))
    (home-page "https://github.com/letoram/xarcan")
    (synopsis "Patched Xserver that bridges to arcan")
    (description "Patched Xserver that bridges to arcan")
    (license license:expat))))
