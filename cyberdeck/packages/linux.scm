(define-module (cyberdeck packages linux)
  #:use-module (guix build utils)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nongnu packages linux))

;; XXX: use guix-internal make-linux-libre* behind the curtain
(define* (make-custom-linux version
                            source
                            supported-systems
                            #:key
                            (extra-version #f)
                            (extra-options '()))
  (package
    (inherit ((@@ (gnu packages linux) make-linux-libre*)
              version
              "gnu"
              source
              supported-systems
              #:extra-version extra-version
              #:extra-options extra-options))
    (name (if extra-version
              (string-append "linux-custom-" extra-version)
              "linux-custom"))
    (home-page "https://www.kernel.org/")
    (synopsis "Customized Linux kernel")
    (description "Custom build of Linux, with no helpful metadata")))

(define linux-surface-extra-options-common
  `(("CONFIG_APDS9960" . m)
    ("CONFIG_BATTERY_SURFACE" . m)
    ("CONFIG_CHARGER_SURFACE" . m)
    ("CONFIG_CIO2_BRIDGE" . #t)
    ("CONFIG_INPUT_SOC_BUTTON_ARRAY" . m)
    ("CONFIG_INTEL_MEI" . m)
    ("CONFIG_INTEL_MEI_HDCP" . m)
    ("CONFIG_INTEL_MEI_ME" . m)
    ("CONFIG_INTEL_MEI_TXE" . m)
    ("CONFIG_INTEL_SKL_INT3472" . m)
    ("CONFIG_MISC_IPTS" . m)
    ("CONFIG_SURFACE_3_BUTTON" . m)
    ("CONFIG_SURFACE_3_POWER_OPREGION" . m)
    ("CONFIG_SURFACE_ACPI_NOTIFY" . m)
    ("CONFIG_SURFACE_AGGREGATOR" . m)
    ("CONFIG_SURFACE_AGGREGATOR_BUS" . #t)
    ("CONFIG_SURFACE_AGGREGATOR_CDEV" . m)
    ("CONFIG_SURFACE_AGGREGATOR_ERROR_INJECTION" . #f)
    ("CONFIG_SURFACE_AGGREGATOR_REGISTRY" . m)
    ("CONFIG_SURFACE_BOOK1_DGPU_SWITCH" . m)
    ("CONFIG_SURFACE_DTX" . m)
    ("CONFIG_SURFACE_GPE" . m)
    ("CONFIG_SURFACE_HID" . m)
    ("CONFIG_SURFACE_HOTPLUG" . m)
    ("CONFIG_SURFACE_KBD" . m)
    ("CONFIG_SURFACE_PLATFORM_PROFILE" . m)
    ("CONFIG_SURFACE_PRO3_BUTTON" . m)
    ("CONFIG_VIDEO_IPU3_CIO2" . m)
    ("CONFIG_VIDEO_IPU3_IMGU" . m)
    ("CONFIG_VIDEO_OV5693" . m)
    ("CONFIG_VIDEO_OV8865" . m)))

(define-public linux-surface-6.1
  (customize-linux
   #:name "surface"
   (origin
     (method url-fetch)
     (uri "https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.1.11.tar.xz")
     (sha256 (base32 "17qr061b617g64s60svw7lf9s5vn5zwd1y96cwckjpr5shcn1fxq"))
     (patches
      (parameterize
          ((%patch-path
            (map (lambda (directory)
                   (string-append directory "/cyberdeck/packages/patches/linux-surface/6.1"))
                 %load-path)))
        (search-patches "0001-surface3-oemb.patch"
                        "0002-mwifiex.patch"
                        "0003-ath10k.patch"
                        "0004-ipts.patch"
                        "0005-ithc.patch"
                        "0006-surface-sam.patch"
                        "0007-surface-sam-over-hid.patch"
                        "0008-surface-button.patch"
                        "0009-surface-typecover.patch"
                        "0010-cameras.patch"
                        "0011-amd-gpio.patch"
                        "0012-rtc.patch"))))))

(define-public linux-surface-5.19
  (make-custom-linux
   "5.19.7"
   (origin
     (method url-fetch)
     (uri "https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.19.7.tar.xz")
     (sha256 (base32 "17qr061b617g64s60svw7lf9s5vn5zwd1y96cwckjpr5shcn1fxq"))
     (patches
      (parameterize
       ((%patch-path
         (map (lambda (directory)
                (string-append directory "/cyberdeck/packages/patches/linux-surface/5.19"))
              %load-path)))
       (search-patches "0001-surface3-oemb.patch"
                       "0002-mwifiex.patch"
                       "0003-ath10k.patch"
                       "0004-ipts.patch"
                       "0005-surface-sam.patch"
                       "0006-surface-sam-over-hid.patch"
                       "0007-surface-button.patch"
                       "0008-surface-typecover.patch"
                       "0009-surface-gpe.patch"
                       "0010-cameras.patch"
                       "0011-amd-gpio.patch"))))
  '("x86_64-linux")
  #:extra-version "surface"
  #:extra-options linux-surface-extra-options-common))
