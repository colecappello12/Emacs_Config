; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

; Initialize use-package on non-linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)  ;disable scrollbar
(tool-bar-mode -1)    ;disable toolbar
(tooltip-mode -1)     ;disable tooltips
(set-fringe-mode 10)  ;Give breathing room

(menu-bar-mode -1)    ;Disable menu bar

                                        ;Control amount of scrolling
(setq  next-screen-context-lines 20)

;; Set up visible bell
                                        ;(setq visible-bell t)

(set-face-attribute 'default nil :font "Fira Code" :height 140)  

(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
                pdf-view-mode-hook
                treemacs-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package doom-themes
  :init(load-theme 'doom-palenight t))

(use-package all-the-icons)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 15))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay .3))

(use-package counsel
    :bind(("M-x" . counsel-M-x)
          ("C-x b" . counsel-ibuffer)
          ("C-x C-f" . counsel-find-file)
          :map minibuffer-local-map
          ("C-r" . counsel-minibuffer-history))
    :config
    (setq ivy-initial-inputs-alist nil))


  (use-package ivy
    :diminish
    :bind (("C-s" . swiper)
           :map ivy-minibuffer-map
           ("TAB" . ivy-alt-done)	
           ("C-l" . ivy-alt-done)
           ("C-j" . ivy-next-line)
           ("C-k" . ivy-previous-line)
           :map ivy-switch-buffer-map
           ("C-k" . ivy-previous-line)
           ("C-l" . ivy-done)
           ("C-d" . ivy-switch-buffer-kill)
           :map ivy-reverse-i-search-map
           ("C-k" . ivy-previous-line)
           ("C-d" . ivy-reverse-i-search-kill))
    :init
    (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package ivy-prescient
  :after counsel
  :config (ivy-prescient-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(defun cc/org-mode-setup ()
  (org-indent-mode)
  (visual-line-mode 1))

; can use this setting to play with font of org mode
; (variable-pitch-mode 1)


(use-package org
  :hook (org-mode . cc/org-mode-setup) 
  :config

  (setq org-refile-targets
    '(("~/Code/Org Mode/Archive.org" :maxlevel . 1)
      ("~/Code/Org Mode/Tasks.org" :maxlevel . 1)))

  ;save org files after refiling
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/Code/Org Mode/Tasks.org"
          "~/Code/Org Mode/Teaching.org"
          "~/Code/Org Mode/Habits.org"
          "~/Code/Org Mode/Classes.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

   (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work/school" . ?W)))

  (setq org-agenda-custom-commands
        (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Code/Org Mode/Tasks.org" "Inbox")
       "* TODO  %?\n  %U\n  %a\n  %i" :empty-lines 1)
      ("ts" "Active Timestamp Task" entry (file+olp "~/Code/Org Mode/Tasks.org" "Inbox")
       "* TODO %^t  %?\n  %U\n  %a\n  %i" :empty-lines 1))))


  (setq org-ellipsis " ▾"))

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)


  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun cc/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . cc/org-mode-visual-fill))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (emacs-lisp . t)
   (python . t)))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp\n"))
(add-to-list 'org-structure-template-alist '("py" . "src python :session *python* :results output\n"))
(add-to-list 'org-structure-template-alist '("R" . "src R :session *R* :results output\n"))

;; Automatically tangle our Emacs.org config file when we save it


(defun efs/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/Emacs-Config.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook
  (lsp-mode . efs/lsp-mode-setup)
  ;(ess-r-mode . lsp-deferred)       
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Code")
    (setq projectile-project-search-path '("~/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(setq auth-sources '("~/.authinfo"))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge)

;See lsp-mode pyright github for info
(use-package lsp-pyright
  :ensure t
  :custom (lsp-pyright-langserver-command "pyright")  ;; or basedpyright
  ;(lsp-pyright-venv-path '"/opt/anaconda3/envs/")

  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred))))  ; or lsp-deferred

;See github for conda.el
(use-package conda
  :ensure t
  :config
  (conda-env-initialize-interactive-shells)
  (conda-env-initialize-eshell)

  :custom
  (conda-anaconda-home '"/opt/anaconda3/"))

(use-package ess
  :ensure t
  :init
  (require 'ess-r-mode))

(use-package polymode
  :ensure t)
  ;:init (setq poly-mode-lsp-integration nil)

(defun my-rstudio-layout () ""
            (interactive)
            (add-to-list 'display-buffer-alist
                         '((derived-mode . ess-mode)
                           (disply-buffer-reuse-window)
                           (side .  left)
                           (slot . -1)
                           (dedicated . t)
                           (tab-group . "rstudio-1")))

            (add-to-list 'display-buffer-alist
                         `("^\\*help\\[R\\]"
                           (display-buffer-reuse-mode-window  display-buffer-in-side-window)
                           (mode . '(ess-help-mode));xwidget-webkit-mode
                           (side . right)
                           (slot . 1)
                           (window-width . 0.33)
                           (dedicated . nil)))

            (add-to-list 'display-buffer-alist              
                   '((derived-mode . dired-mode)
                   (display-buffer-reuse-mode-window  display-buffer-in-side-window)
;                  (mode . '(dired-mode));xwidget-webkit-mode
                   (side . right)
                   (slot . 1)
                   (window-width . 0.33)
                   (dedicated . nil)))

            (add-to-list 'display-buffer-alist
                         `("^\\*R.*\\*"
                           (display-buffer-reuse-mode-window display-buffer-at-bottom)
                           (mode . ess-mode)
                           (window-width . 0.5)
                           (window-height . 0.25)
                           (dedicated . t)
                           (tab-group "rstudio-3")))

            (add-to-list 'display-buffer-alist
                         `("^\\*R dired\\*"
                           (display-buffer-reuse-mode-window display-buffer-in-side-window)
                           (mode . ess-rdired-mode)
                           (side . right)
                           (slot . -1)
                           (window-width . 0.33)
                           (dedicated . t)
                           (reusable-frames . nil)
                           (tab-group . "rstudio-2")))

            (let ((ess-startup-directory 'default-directory)
                  (ess-ask-for-ess-directory nil))
              (delete-other-windows)
              (ess-switch-to-ESS t)
              (ess-rdired)
              (ess-help "help")
              (tab-line-mode 1)
              (my-start-hdg)))

(use-package company
  :after lsp-mode
  :hook
  (lsp-mode . company-mode)
  (ess-r-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package prescient)

;Autocompletions sorted by most used
(use-package company-prescient
  :after company
  :config (company-prescient-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package pdf-tools
  :ensure t)
(pdf-tools-install)

(setq insert-directory-program "gls" 
      dired-use-ls-dired t)

(use-package dired
  :ensure nil
  :commands(dired dired-jump)
  :hook (dired-mode . dired-omit-mode)
  :bind (:map dired-mode-map
          ( "."     . dired-omit-mode))                 ;Set "." to toggle omit mode
  :custom ((dired-listing-switches "-agho --group-directories-first")
           (dired-kill-when-opening-new-dired-buffer t) ;Only one dired buffer at a time
           (dired-omit-files (rx (seq bol ".")))))
