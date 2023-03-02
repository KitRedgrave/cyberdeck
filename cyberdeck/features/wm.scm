(define-module (cyberdeck features wm)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sddm)
  #:use-module (gnu system keyboard)
  #:use-module (rde home services wm)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (rde features)
  #:use-module (rde features predicates)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)

  #:export (feature-awesomewm
            feature-sway))

(define* (feature-awesomewm
          #:key
          (awesome awesome))
  "Setup and configure awesome."

  (define (awesomewm-system-services config)
    (list
     (service sddm-service-type)
     (simple-service
      'add-awesomewm-packages
      profile-service-type
      (list
       awesome
       rofi
       rofi-pass
       arc-icon-theme
       xscreensaver))))

  (feature
   (name 'awesomewm)
   (values '((awesome . awesome)))
   (system-services-getter awesomewm-system-services)))

(define (keyboard-layout-to-sway-config keyboard-layout)
  (let* ((kb-options (keyboard-layout-options keyboard-layout))
         (xkb-options (and (not (null? kb-options))
                           (string-join kb-options ",")))
         (xkb-variant (keyboard-layout-variant keyboard-layout)))
    `((input *
             ((xkb_layout  ,(keyboard-layout-name keyboard-layout))
              ,@(if xkb-variant `((xkb_variant ,xkb-variant)) '())
              ,@(if xkb-options `((xkb_options ,xkb-options)) '()))))))



(define* (feature-i3
          #:key
          (extra-config '())
          (i3 i3)
          (alacritty alacritty)
          (rofi rofi)
          (xdg-desktop-portal xdg-desktop-portal)
          ;; Logo key. Use Mod1 for Alt.
          (i3-mod 'Mod4))
  "Setup and configure i3."
  (ensure-pred sway-config? extra-config)
  (ensure-pred boolean? add-keyboard-layout-to-config?)
  (ensure-pred any-package? i3)
  (ensure-pred any-package? rofi)
  (ensure-pred any-package? alacritty)
  (ensure-pred any-package? xdg-desktop-portal)

  (define (i3-system-services config)
    (list
     (service sddm-service-type
              (sddm-configuration
               (display-server "x11")))
     (simple-service
      'packages-for-sway
      profile-service-type
      (list i3))))

  (define (i3-home-services config)
    "Returns home services related to i3."
    (let* ((kb-layout      (get-value 'keyboard-layout config)))

           (lock-cmd
            (get-value 'default-screen-locker config "loginctl lock-session"))

           (default-terminal
             (get-value-eval 'default-terminal config
                             (file-append alacritty "/bin/alacritty")))
           (backup-terminal
             (get-value 'backup-terminal config
                        (file-append alacritty "/bin/alacritty")))
           (default-application-launcher
             (get-value 'default-application-launcher config
                        (file-append rofi "/bin/rofi")))

           (default-password-launcher
             (get-value 'default-password-launcher config
                        (file-append rofi-pass "/bin/rofi-pass")))

           (default-notification-handler
             (get-value 'default-notification-handler config
                        (file-append dunst "/bin/dunst")))

           (shepherd-configuration (home-shepherd-configuration
                                    (auto-start? #f)
                                    (daemonize? #f)))
           (shepherd (home-shepherd-configuration-shepherd shepherd-configuration)))
      (list
       (service home-shepherd-service-type shepherd-configuration)
       (simple-service
        'sway-launch-shepherd
        home-sway-service-type
        `((,#~"\n\n# Launch shepherd:")
          (exec ,(program-file
                  "launch-shepherd"
                  #~(let ((log-dir (or (getenv "XDG_LOG_HOME")
                                       (format #f "~a/.local/var/log"
                                               (getenv "HOME")))))
                      (system*
                       #$(file-append shepherd "/bin/shepherd")
                       "--logfile"
                       (string-append log-dir "/shepherd.log")))))))

       (service
        home-sway-service-type
        (home-sway-configuration
         (package sway)
         (config
          `((,#~"")
            ,@layout-config

            (,#~"\n\n# General settings:")
            (set $mod ,i3-mod)

            (floating_modifier $mod normal)

            (bindsym --to-code $mod+Shift+r reload)

            (,#~"\n\n# Launching external applications:")
            (set $term ,default-terminal)
            (set $backup-term ,backup-terminal)
            (set $pass ,default-password-launcher)
            (set $menu ,default-application-launcher)
            (set $lock ,lock-cmd)


            (bindsym $mod+Control+Shift+Return exec $backup-term)
            (bindsym $mod+Return exec $term)

            (bindsym --to-code $mod+d exec $menu)
            (bindsym --to-code $mod+p exec $pass)
            (bindsym --to-code $mod+q exec $lock)

            (,#~"\n\n# Manipulating windows:")
            (bindsym --to-code $mod+Shift+q kill)
            (bindsym --to-code $mod+f fullscreen)
            (bindsym $mod+Shift+space floating toggle)
            (bindsym $mod+Ctrl+space focus mode_toggle)

            (bindsym $mod+h focus left)
            (bindsym $mod+j focus down)
            (bindsym $mod+k focus up)
            (bindsym $mod+l focus right)

            (bindsym $mod+Shift+h move left)
            (bindsym $mod+Shift+j move down)
            (bindsym $mod+Shift+k move up)
            (bindsym $mod+Shift+l move right)

            (bindsym $mod+b splith)
            (bindsym $mod+v splitv)

            (bindsym $mod+s layout stacking)
            (bindsym $mod+w layout tabbed)
            (bindsym $mod+e layout toggle split)

            (for_window "[window_role=\"pop-up\"]" floating enabled)
            (for_window "[window_role=\"bubble\"]" floating enabled)
            (for_window "[window_role=\"task_dialog\"]" floating enable)
            (for_window "[window_role=\"Preferences\"]" floating enable)
            (for_window "[window_role=\"dialog\"]" floating enable)
            (for_window "[window_role=\"menu\"]" floating enable)
            (for_window "[window_role=\"About\"]" floating enable)

            (,#~"\n\n# Moving around workspaces:")
            (bindsym $mod+tab workspace back_and_forth)
            ,@(append-map
               (lambda (x)
                 `((bindsym ,(format #f "$mod+~a" (modulo x 10))
                            workspace number ,x)
                   (bindsym ,(format #f "$mod+Shift+~a" (modulo x 10))
                            move container to workspace number ,x)))
               (iota 10 1))

            (bar
             ((mode dock)
              (position top)
              (modifier $mod)
              (status_command "while date +'%Y.%-m.%-d %H:%M:%S'; do sleep 1; done")
              (colors
               ((statusline "#DCDCCC")
                (background "#3A3A3A")))))

            (,#~"")
            (default_border pixel)
            (default_floating_border pixel)
            (gaps inner ,(get-value 'emacs-margin config 8))))))

       (when (get-value 'swayidle-cmd config)
         (simple-service
          'sway-enable-swayidle
          home-sway-service-type
          `((,#~"")
            (exec ,(get-value 'swayidle-cmd config)))))

       (when (get-value 'swayidle config)
         (let* ((swaymsg (file-append sway "/bin/swaymsg"))
                (swaymsg-cmd (lambda (cmd)
                               #~(format #f "'~a \"~a\"'" #$swaymsg #$cmd)))
                (idle-timeout (+ 30 (get-value 'lock-timeout config 120))))
           (simple-service
            'sway-add-dpms-to-swayidle
            home-swayidle-service-type
            `((timeout ,idle-timeout ,(swaymsg-cmd "output * dpms off")
               resume                ,(swaymsg-cmd "output * dpms on"))))))

       (when (get-value 'default-notification-handler config)
         (simple-service
          'i3-enable-dunst
          home-sway-service-type
          `((,#~"")
            (exec ,(get-value 'default-notification-handler config)))))

       (simple-service
        'sway-configuration
        home-sway-service-type
        `(,@extra-config
          (,#~"")))

       (simple-service
        'sway-reload-config-on-change
        home-run-on-change-service-type
        `(("files/.config/sway/config"
           ,#~(system* #$(file-append sway "/bin/swaymsg") "reload"))))

       (simple-service
        'xdg-desktop-portal-wlr-configuration
        home-xdg-configuration-files-service-type
        `(("xdg-desktop-portal-wlr/config"
           ,(mixed-text-file
             "xdg-desktop-portal-wlr-config"
             #~(format #f "[screencast]
output_name=
max_fps=30
chooser_cmd=~a -f %o -or -c ff0000
chooser_type=simple"
                       #$(file-append (get-value 'slurp config slurp)
                                      "/bin/slurp"))))))

       (simple-service
        'packages-for-sway
        home-profile-service-type
        (append
         (if (and (get-value 'default-terminal config)
                  (get-value 'backup-terminal config))
             '() (list foot))
         (if (get-value 'default-application-launcher config) '() (list fuzzel))
         (if (get-value 'default-password-launcher config) '() (list tessen))
         (if (get-value 'default-notificaton-handler config) '() (list mako))
         (list qtwayland-5 swayhide
               xdg-desktop-portal xdg-desktop-portal-wlr))))))

  (feature
   (name 'sway-cyberdeck)
   (values `((sway . ,sway)
             (wl-clipboard . ,wl-clipboard)
             (wayland . #t)
             (xwayland? . ,xwayland?)))
   (home-services-getter sway-home-services)
   (system-services-getter sway-system-services)))
