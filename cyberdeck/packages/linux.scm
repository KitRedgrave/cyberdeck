(define-module (cyberdeck packages linux)
  #:use-module (guix build utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system linux-module)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nongnu packages linux))

;; TODO: finish customize-linux knockoff that doesn't fuck up with
;; a nonreproducible defconfig getting in my way
;; see guix/gnu/build/kconfig, gnu/packages/linux
(define* (my-customize-linux #:key name
                                (linux linux-libre)
                                source
                                defconfig
                                (configs "")
                                extra-version)
  "See guix/gnu/packages/linux.scm:customize-linux for docs"
  (package
    (inherit linux)
    (name (or name (package-name linux)))
    (source (or source (package-source linux)))
    (arguments
     (substitute-keyword-arguments
         (package-arguments linux)
       ((#:imported-modules imported-modules %gnu-build-system-modules)
        `((guix build kconfig) ,@imported-modules))
       ((#:modules modules)
        `((guix build kconfig) ,@modules))
       ((#:phases phases)
        #~(modify-phases #$phases
            (replace 'configure
              (lambda* (#:key inputs #:allow-other-keys #:rest arguments)
                (setenv "EXTRAVERSION"
                        #$(and extra-version
                               (not (string-null? extra-version))
                               (string-append "-" extra-version)))
                (let* ((configs (string-append "arch/x86/configs/"))
                       (guix_defconfig (string-append configs
                                                      "guix_defconfig")))
                  #$(cond
                     ((not defconfig)
                      #~(begin
                          (apply (assoc-ref #$phases 'configure) arguments)
                          (invoke "make" "savedefconfig")
                          (rename-file "defconfig" guix_defconfig)))
                     ((string? defconfig)
                      #~(rename-file (string-append config #$defconfig)
                                     guix_defconfig))
                     (else
                      #~(copy-file #$defconfig guix_defconfig)))
                (chmod guix_defconfig #o644)
                (modify-defconfig guix_defconfig '#$configs)
                (invoke "make" "guix_defconfig"))))))))))


(define-public linux-surface-6.1
  (my-customize-linux
   #:name "linux-surface"
   #:source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/linux-surface/kernel")
                    (commit "v6.1-surface")))
              (sha256 (base32 "04m5v8bkmp7kiw7crhjqjcixpix80sss6jlhwy951cwfc7cc7pgw")))
   #:extra-version "surface"
   #:configs (list "CONFIG_SURFACE_AGGREGATOR=m"
                   "CONFIG_SURFACE_AGGREGATOR_BUS=y"
                   "CONFIG_SURFACE_AGGREGATOR_CDEV=m"
                   "CONFIG_SURFACE_AGGREGATOR_HUB=m"
                   "CONFIG_SURFACE_AGGREGATOR_REGISTRY=m"
                   "CONFIG_SURFACE_AGGREGATOR_TABLE_SWITCH=m"
                   "CONFIG_SURFACE_ACPI_NOTIFY=m"
                   "CONFIG_SURFACE_DTX=m"
                   "CONFIG_SURFACE_PLATFORM_PROFILE=m"
                   "CONFIG_SURFACE_HID=m"
                   "CONFIG_SURFACE_KBD=m"
                   "CONFIG_BATTERY_SURFACE=m"
                   "CONFIG_CHARGER_SURFACE=m"
                   "CONFIG_SURFACE_HOTPLUG=m"
                   "CONFIG_HID_IPTS=m"
                   "CONFIG_HID_ITHC=m"
                   "CONFIG_VIDEO_DW9719=m"
                   "CONFIG_VIDEO_IPU3_IMGU=m"
                   "CONFIG_VIDEO_IPU3_CIO2=m"
                   "CONFIG_CIO2_BRIDGE=y"
                   "CONFIG_INTEL_SKL_INT3472=m"
                   "CONFIG_REGULATOR_TPS68470=m"
                   "CONFIG_COMMON_CLK_TPS68470=m"
                   "CONFIG_VIDEO_OV5693=m"
                   "CONFIG_VIDEO_OV7251=m"
                   "CONFIG_VIDEO_OV8865=m"
                   "CONFIG_APDS9960=m"
                   "CONFIG_INPUT_SOC_BUTTON_ARRAY=m"
                   "CONFIG_SURFACE_3_POWER_OPREGION=m"
                   "CONFIG_SURFACE_PRO3_BUTTON=m"
                   "CONFIG_SURFACE_GPE=m"
                   "CONFIG_SURFACE_BOOK1_DGPU_SWITCH=m")))
