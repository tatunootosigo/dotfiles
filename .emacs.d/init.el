;;; ロードパスの追加
(setq load-path (append
		 '(;;"~/.emacs.d"
		   "~/.emacs.d/lisp")
		 load-path))
;;(require 'emacsc)
;;(require 'ediff-batch)

(require 'package)
;;(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/"))
(fset 'package-desc-vers 'package--ac-desc-version)
(package-initialize)

(fset 'yes-or-no-p 'y-or-n-p)          ; (yes/no) を (y/n)に

(global-hl-line-mode t)                         ;; 現在行をハイライト
(show-paren-mode t)                             ;; 対応する括弧をハイライト
(setq show-paren-style 'mixed)                  ;; 括弧のハイライトの設定。
(transient-mark-mode t)                         ;; 選択範囲をハイライト
(setq-default tab-width 2 indent-tabs-mode nil) ;; インデントを2つのスペースに
(setq js-indent-level 2 indent-tabs-mode nil)   ;; jsファイルの編集でもインデントをスペース2つに
(setq require-final-newline t)                  ;; 最終行にEOF追加
(setq scroll-conservatively 1)                  ;; 画面のスクロールを一行ずつにする
(setq ruby-insert-encoding-magic-comment nil)   ;; ruby-mode時、先頭行にcoding: utf-8を入れない
(menu-bar-mode -1)                              ;; メニューバーを非表示
(setq-default show-trailing-whitespace t)       ;; 行末の空白を表示

;; 行数表示
(global-linum-mode t)
(defvar linum-padding-number 0) ;;行番号の頭に付ける空白の数
(unless window-system
  (add-hook 'linum-before-numbering-hook
	    (lambda ()
	      (setq-local linum-format-fmt
			  (let ((w (length (number-to-string
					    (count-lines (point-min) (point-max))))))
			    (concat "%" (number-to-string (+ w linum-padding-number)) "d||"))))))
(defun linum-format-func (line)
  (propertize (format linum-format-fmt line) 'face 'linum))
(unless window-system
  (setq linum-format 'linum-format-func))

;; volatile-highlights(ペーストした時とかにわかりやすくなる)
(require 'volatile-highlights)
(volatile-highlights-mode t)
;; Supporting undo-tree.
(vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
(vhl/install-extension 'undo-tree)

(load-theme 'tango-dark t)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:foreground "#F8F8F2" :background "#1B1D1E"))))
 '(hl-line ((t (:background "#485050"))))
 '(mode-line ((t (:foreground "#FFFFFF" :background "#404242"))))
 '(region ((t (:background "#305050")))))
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region) ; M+; でコメントアウト
(keyboard-translate ?\C-h ?\C-?) ;C+hをbackspaseに

;; git-gutter+
;; gitの差分があるかどうかわかりやすく
(require 'fringe-helper)
(global-git-gutter+-mode)

(require 'web-mode)
;;; emacs 23以下の互換
;;(when (< emacs-major-version 24)
;;  (defalias 'prog-mode 'fundamental-mode))
;;; 適用する拡張子
(setq web-mode-html-offset   2)
(setq web-mode-style-padding 2)
(setq web-mode-css-offset    2)
(setq web-mode-script-offset 2)
(setq web-mode-java-offset   2)
(setq web-mode-asp-offset    2)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-hook 'web-mode-hook '(lambda ()
			    (electric-indent-local-mode -1)))

;; flycheck
(require 'flycheck)
(add-hook 'ruby-mode-hook
	  '(lambda ()
	     (setq flycheck-select-checker '(ruby-rubocop))
	     (setq flycheck-disabled-checkers '(ruby-rubylint))
	     (flycheck-mode 1)))

(flycheck-define-checker ruby-rubocop
			 "A Ruby syntax and style checker using the RuboCop tool."
			 :command ("rubocop" "--format" "emacs"
				   (config-file "--config" flycheck-rubocoprc)
				   source)
			 :error-patterns
			 ((warning line-start
				   (file-name) ":" line ":" column ": " (or "C" "W") ": " (message)
				   line-end)
			  (error line-start
				 (file-name) ":" line ":" column ": " (or "E" "F") ": " (message)
				 line-end))
			 :modes (ruby-mode motion-mode))


(require 'flycheck-color-mode-line)
(eval-after-load "flycheck"
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; robe
;;(add-hook 'ruby-mode-hook
;;        '(lambda ()
;;           (robe-mode)
;;           (robe-ac-setup)
;;           (inf-ruby-keys)
;;                        ))

;; Auto Complete
;; auto-complete-config の設定ファイルを読み込む。
(require 'auto-complete-config)
(ac-config-default)
;; TABキーで自動補完を有効にする
(ac-set-trigger-key "TAB")
;; auto-complete-mode を起動時に有効にする
(global-auto-complete-mode t)

;; company(自動補完)
;;(require 'company)
;;(global-company-mode) ; 全バッファで有効にする
;;(setq company-idle-delay 0) ; デフォルトは0.5
;;(setq company-minimum-prefix-length 2) ; デフォルトは4
;;(setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る

;; undo-tree
;;
;; undo-tree を読み込む
(require 'undo-tree)

;; undo-tree を起動時に有効にする
(global-undo-tree-mode t)

;; M-/ をredo に設定する。
(global-set-key (kbd "M-/") 'undo-tree-redo)

;; ediff
;; コントロール用のバッファを同一フレーム内に表示
;;(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; diffのバッファを上下ではなく左右に並べる
;;(setq ediff-split-window-function 'split-window-horizontally)

;; モードラインに列番号表示
(column-number-mode 1)
;; モードラインに行番号表示
(line-number-mode 1)

;; 複数カーソル関連
(require 'multiple-cursors)
(require 'smartrep)

(declare-function smartrep-define-key "smartrep")

(global-set-key (kbd "C-M-c") 'mc/edit-lines)
(global-set-key (kbd "C-M-r") 'mc/mark-all-in-region)

(global-unset-key "\C-t")

(smartrep-define-key global-map "C-t"
		     '(("C-t"      . 'mc/mark-next-like-this)
		       ("n"        . 'mc/mark-next-like-this)
		       ("p"        . 'mc/mark-previous-like-this)
		       ("m"        . 'mc/mark-more-like-this-extended)
		       ("u"        . 'mc/unmark-next-like-this)
		       ("U"        . 'mc/unmark-previous-like-this)
		       ("s"        . 'mc/skip-to-next-like-this)
		       ("S"        . 'mc/skip-to-previous-like-this)
		       ("*"        . 'mc/mark-all-like-this)
		       ("d"        . 'mc/mark-all-like-this-dwim)
		       ("i"        . 'mc/insert-numbers)
		       ("o"        . 'mc/sort-regions)
		       ("O"        . 'mc/reverse-regions)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line-format
   (quote
    ("%e" mode-line-front-space mode-line-mule-info mode-line-client mode-line-modified mode-line-remote mode-line-frame-identification mode-line-buffer-identification mode-line-position smartrep-mode-line-string mode-line-modes mode-line-misc-info mode-line-end-spaces))))
