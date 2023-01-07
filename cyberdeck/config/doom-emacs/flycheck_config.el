(setq user-full-name "Catherine Alice Redgrave"
      user-mail-address "me@constructed.space")

(setq doom-font (font-spec :family "Source Code Pro" :size 15)
      doom-variable-pitch-font (font-spec :family "Source Sans 3")
      doom-theme 'doom-zenburn)

(setq doom-modeline-major-mode-icon t
      doom-modeline-persp-name t
      doom-modeline-persp-icon t
      doom-modeline-lsp t)

(use-package! hyperbole
  :hook (fundamental-mode . hyperbole-mode))

(use-package! geiser-guile
  :config
  (add-to-list 'geiser-guile-load-path "/home/alice/.config/guix/current/share/guile/site/3.0"))

(use-package! guix
  :hook (scheme-mode . guix-devel-mode))

(use-package! yasnippet
  :config
  (add-to-list 'yas-snippet-dirs "/home/alice/projects/guix/etc/snippets")
  (yas-reload-all))

(setq magit-repository-directories '(("~/projects" . 1))
      magit-save-repository-buffers nil
      magit-inhibit-save-previous-winconf t
      transient-values '((magit-rebase "--autosquash" "--autostash")
                         (magit-pull "--rebase" "--autostash")
                         (magit-revert "--autostash")))

(setq org-directory "~/Documents/org"
      org-roam-directory org-directory
      org-roam-db-location (concat org-directory ".org-roam.db")
      org-agenda-files '("~/Documents/org/"))


(setq +doom-quit-messages
      (append +doom-quit-messages
              '(;; least objectionable unused doom 2 messages
                ;; credit: https://tcrf.net/Doom_II:_Hell_on_Earth_(PC)
                "hey ron, can we say 'fuck' in the game?"
                "i'd leave: this is just more monsters and levels. what a load."
                "don't quit now! we're still spending your money!"
                "THIS IS NO MESSAGE! Page intentionally left blank.")))

(use-package! tree-sitter)
(use-package! tree-sitter-langs)

(use-package! whitespace
  :config
  (setq whitespace-style '(face tabs tab-mark spaces space-mark))
  (setq whitespace-display-mappings
        '((space-mark   ?\    [?\xB7]     [?\.])
          (space-mark   ?\xA0 [?\xA4]     [?\_])
          (newline-mark ?\n   [?\xB6 ?\n] [?$ ?\n]))))

(context-menu-mode 1)
