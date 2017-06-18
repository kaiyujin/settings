(setq load-path (cons (expand-file-name "~/.emacs.d/lisp") load-path))
;; el-get
(add-to-list 'load-path (locate-user-emacs-file "el-get"))
(require 'el-get)
;; el-getでダウンロードしたパッケージは ~/.emacs.d/ に入るようにする
(setq el-get-dir (locate-user-emacs-file "lisp"))
;go
(el-get-bundle! go-mode)
(el-get-bundle! go-autocomplete)
(el-get-bundle! go-eldoc)
(setenv "GOPATH" "/Users/shiraishidaisuke/tools/gopath")
(add-to-list 'exec-path (expand-file-name "~/tools/gopath/bin"))
(add-hook 'go-mode-hook (lambda ()
			  (setq gofmt-command "goimports")
			  (setq tab-width 2)
			  (add-hook 'before-save-hook 'gofmt-before-save)))
(require 'go-autocomplete)

;;行番号
(require 'linum)
(global-linum-mode 1)
(setq linum-format "%1d ")
(setq ring-bell-function (lambda ()));ベル無音、フラッシュ解除
(setq delete-auto-save-files t);終了時にオートセーブファイルを消す
(setq delete-auto-save-save nil);終了時にオートセーブファイルを消す
(setq backup-inhibited t);バックアップを作らない
(setq column-number-mode t);カーソルの位置が何文字目か表示
(setq kill-whole-line t);C-kで行全体を削除
(setq require-final-newline t);最終行に必ず一行挿入
(recentf-mode);最近使ったファイルを保存M-x recntf-open-filesでひらける
(transient-mark-mode t);リージョンに色つけ
(show-paren-mode t);対応する括弧を表示
(setq tab-width 2 );tab width
(global-font-lock-mode t);色つけ
(setq inhibit-startup-message t);ver22で初期表示画面を表示させない
(global-set-key "\M-g" 'goto-line); M-g で指定行へ移動
(define-key global-map "\C-h" 'delete-backward-char); C-h でカーソルの左にある文字を消す
(define-key global-map "\C-o" 'dabbrev-expand); C-o に動的略語展開機能を割り当てる
(setq dabbrev-case-fold-search nil) ; 大文字小文字を区別
;;自動chmod
(defun make-file-executable ()
  "Make the file of this buffer executable, when it is a script source."
  (save-restriction
    (widen)
    (if (string= "#!" (buffer-substring-no-properties 1 (min 3 (point-max))))
        (let ((name (buffer-file-name)))
          (or (equal ?. (string-to-char (file-name-nondirectory name)))
              (let ((mode (file-modes name)))
                (set-file-modes name (logior mode (logand (/ mode 4) 73)))
                (message (concat "Wrote " name " (+x)"))))))))
(add-hook 'after-save-hook 'make-file-executable)

;;日本語入力
(set-language-environment "Japanese")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;;略称展開
(quietly-read-abbrev-file)
(setq save-abbrevs t)
(setq abbrev-file-name "~/.abbrev_defs")
(define-key esc-map  " " 'expand-abbrev) ;; M-SPC
;;c言語
(add-hook 'c-mode-common-hook
          '(lambda ()
             ;; センテンスの終了である ';' を入力したら、自動改行+インデント
             (c-toggle-auto-hungry-state 1)
             ;; RET キーで自動改行+インデント
             (define-key c-mode-base-map "\C-m" 'newline-and-indent)
))
;;ruby-mode
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files")
(setq auto-mode-alist
(append '(("\\.rb$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist
  (append '(("^#!.*ruby" . ruby-mode)) interpreter-mode-alist))

;行末の空白やタブに色をつける
(defface my-face-b-1 '((t (:background "gray"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode (before my-font-lock-mode ())
(font-lock-add-keywords
major-mode
'(("\t" 0 my-face-b-2 append)
("　" 0 my-face-b-1 append)
("[ \t]+$" 0 my-face-u-1 append)
)))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;;色設定
(set-face-foreground 'font-lock-comment-face "darkolivegreen3")
(set-face-foreground 'font-lock-string-face  "coral")
(set-face-foreground 'font-lock-keyword-face "violet")
(set-face-foreground 'font-lock-function-name-face "white")
(set-face-foreground 'font-lock-variable-name-face "white")
(set-face-foreground 'font-lock-type-face "skyblue1")
(set-face-foreground 'font-lock-warning-face "yellow")
(set-face-foreground 'font-lock-builtin-face "goldenrod")
(set-face-background 'highlight "yellow")
(set-face-foreground 'highlight "black")
(set-face-background 'region "lightgoldenrod2")
(set-face-foreground 'region "black")

;ディレクトリ移動でバッファを増やさない
(defun dired-my-advertised-find-file ()
  (interactive)
  (let ((kill-target (current-buffer))
	(check-file (dired-get-filename)))
    (funcall 'dired-advertised-find-file)
    (if (file-directory-p check-file)
	(kill-buffer kill-target))))
(defun dired-my-up-directory (&optional other-window)
"Run dired on parent directory of current directory.
Find the parent directory either in this buffer or another buffer.
Creates a buffer if necessary."
   (interactive "P")
   (let* ((dir (dired-current-directory))
	  (up (file-name-directory (directory-file-name dir))))
     (or (dired-goto-file (directory-file-name dir))
	 ;; Only try dired-goto-subdir if buffer has more than one dir.
	 (and (cdr dired-subdir-alist)
	      (dired-goto-subdir up))
	 (progn
	   (if other-window
	       (dired-other-window up)
	     (progn
	       (kill-buffer (current-buffer))
	       (dired up))
	     (dired-goto-file dir))))))
;(define-key dired-mode-map "\C-m" 'dired-my-advertised-find-file)
;(define-key dired-mode-map "^" 'dired-my-up-directory)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
;add package repo
(package-initialize)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
;helm
(el-get-bundle! helm)
(require 'helm-config)
(helm-mode 1)
(define-key global-map (kbd "M-x") 'helm-M-x)
(define-key global-map (kbd "C-x C-f") 'helm-find-files)
;;key-chord
(el-get-bundle! key-chord)
(require 'key-chord)
(key-chord-mode 1)
;; キーを押した際にどこまでの間隔を許容するか
(setq key-chord-two-keys-delay 0.04)
(key-chord-define-global "gl" 'goto-line)
(key-chord-define-global "fk" 'helm-for-files)
(key-chord-define-global "fj" 'helm-M-x)
;;git grep
(el-get-bundle! helm-git-grep)
(require 'helm-git-grep) ;; Not necessary if installed by package.el
(global-set-key (kbd "C-c g") 'helm-git-grep)
;; Invoke `helm-git-grep' from isearch.
(define-key isearch-mode-map (kbd "C-c g") 'helm-git-grep-from-isearch)
;; Invoke `helm-git-grep' from other helm.
(eval-after-load 'helm
  '(define-key helm-map (kbd "C-c g") 'helm-git-grep-from-helm))
;;tramp-mode
(require 'tramp)
(setq tramp-default-method "ssh")
