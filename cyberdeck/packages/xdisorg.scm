(define-module (cyberdeck packages xdisorg)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages image)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml))

(define-public gdk-pixbuf-xlib
  (package
    (name "gdk-pixbuf-xlib")
    (version "2.40.2")
    (source (origin
              (method url-fetch)
              (uri "https://gitlab.gnome.org/Archive/gdk-pixbuf-xlib/-/archive/2.40.2/gdk-pixbuf-xlib-2.40.2.tar.gz")
              (sha256
               (base32
                 "1zxp1gjhzfmbbm5g0yyalr00fy0p7hdmm3gfh8551djkralbdng7"))))
    (build-system meson-build-system)
    (native-inputs
     (list pkg-config))
    (inputs
     `(("libx11" ,libx11)
       ("gdk-pixbuf" ,gdk-pixbuf)))
    (home-page "https://gitlab.gnome.org/Archive/gdk-pixbuf-xlib")
    (synopsis "Deprecated xlib binding for pixbuf")
    (description "Deprecated xlib binding for pixbuf")
    (license license:lgpl2.1+)))

(define-public xscreensaver
  (package
    (name "xscreensaver")
    (version "6.03")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append "https://www.jwz.org/xscreensaver/xscreensaver-"
                       version ".tar.gz"))
       (sha256
        (base32 "0nm2zd1ppkhix98zd1fprbkk8q7jzdv9xd5sln6gbb2jfdwm339j"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f                      ; no check target
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'adjust-gtk-resource-paths
           (lambda _
             (substitute* '("driver/Makefile.in" "po/Makefile.in.in")
               (("@GTK_DATADIR@") "@datadir@")
               (("@PO_DATADIR@") "@datadir@"))
             #t)))
       #:make-flags (list (string-append "AD_DIR="
                                         (assoc-ref %outputs "out")
                                         "/lib/X11/app-defaults"))))
    (native-inputs
     (list pkg-config intltool))
    (inputs
     `(("libx11" ,libx11)
       ("libxext" ,libxext)
       ("libxi" ,libxi)
       ("libxt" ,libxt)
       ("libxft" ,libxft)
       ("libxmu" ,libxmu)
       ("libxpm" ,libxpm)
       ("libglade" ,libglade)
       ("libxml2" ,libxml2)
       ("libsm" ,libsm)
       ("libjpeg" ,libjpeg-turbo)
       ("linux-pam" ,linux-pam)
       ("pango" ,pango)
       ("gdk-pixbuf-xlib" ,gdk-pixbuf-xlib)
       ("gtk+" ,gtk+)
       ("perl" ,perl)
       ("cairo" ,cairo)
       ("bc" ,bc)
       ("libxrandr" ,libxrandr)
       ("glu" ,glu)
       ("glib" ,glib)))
    (home-page "https://www.jwz.org/xscreensaver/")
    (synopsis "Classic screen saver suite supporting screen locking")
    (description
     "xscreensaver is a popular screen saver collection with many entertaining
demos.  It also acts as a nice screen locker.")
    ;; xscreensaver doesn't have a single copyright file and instead relies on
    ;; source comment headers, though most files have the same lax
    ;; permissions.  To reduce complexity, we're pointing at Debian's
    ;; breakdown of the copyright information.
    (license (license:non-copyleft
              (string-append
               "http://metadata.ftp-master.debian.org/changelogs/"
               "/main/x/xscreensaver/xscreensaver_5.36-1_copyright")))))
