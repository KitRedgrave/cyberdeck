;;; ui/exwm/config.el -*- lexical-binding: t; -*-

(use-package! counsel
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only))

(defun kitredgrave/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun kitredgrave/exwm-update-title ()
  (exwm-workspace-rename-buffer exwm-title))

(use-package! desktop-environment
  :after exwm
  :config
  (setq desktop-environment-screenshot-command "flameshot gui")
  (desktop-environment-mode))

(use-package! exwm
  :commands (exwm-enable)
  :config
  (setq exwm-workspace-show-all-buffers nil)
  (setq exwm-workspace-number 3)
  (add-hook 'exwm-update-class-hook #'kitredgrave/exwm-update-class)
  (add-hook 'exwm-update-title-hook #'kitredgrave/exwm-update-title)
  (setq exwm-input-prefix-keys
        '(?\C-x
          ?\C-u
          ?\C-h
          ?\M-x
          ?\C-w
          ?\M-`
          ?\M-&
          ?\M-:
          ?\M-\
          ?\C-g
          ?\C-\ ))
  (map! :map exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  (require 'exwm-systemtray)
  (setq exwm-systemtray-height 16)
  (exwm-systemtray-enable)

  (require 'exwm-randr)
  (setq exwm-randr-workspace-monitor-plist '(1 "eDP-1"))
  (add-hook 'exwm-randr-screen-change-hook
            (lambda ()
              (start-process-shell-command
               "xrandr" nil "xrandr --output eDP-1 --scale 0.5x0.5 --auto")))
  (exwm-randr-enable)

  (setq display-time-format "[📅 %y/%m/%d %H:%M]")
  (setq display-time-default-load-average nil)
  (display-time-mode 1)
  (exwm-input-set-key (kbd "<s-return>") '+eshell/toggle)
  (setq exwm-input-global-keys
        '(
          ([?\s- ] . counsel-linux-app)
          ([?\s-r] . exwm-reset)
          ([s-left] . windmove-left)
          ([s-right] . windmove-right)
          ([s-up] . windmove-up)
          ([s-down] . windmove-down)

          ([?\s-&] . (lambda (command) (interactive (list (read-shell-command "[command] $")))
                       (start-process-shell-command command nil command)))
          ([?\s-e] . (lambda () (interactive) (dired "~")))
          ([?\s-w] . exwm-workspace-switch)
          ([?\s-Q] . (lambda () (interactive) (kill-buffer)))
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))
          ))
  (setq exwm-input-simulation-keys
        '(([?\C-b] . [left])
          ([?\C-f] . [right])
          ([?\C-p] . [up])
          ([?\C-n] . [down])
          ([?\C-a] . [home])
          ([?\C-e] . [end])
          ([?\M-v] . [prior])
          ([?\C-v] . [next])
          ([?\C-d] . [delete])
          ([?\C-k] . [S-end delete]))))
