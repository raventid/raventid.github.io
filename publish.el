;;; publish.el --- Build raventid.github.io with org-publish  -*- lexical-binding: t; -*-

;; Usage:
;;   make publish            (or: emacs -Q --batch -l publish.el)
;;
;; Org sources live in src/, published HTML lands in the repository
;; root, which is what GitHub Pages serves.  Source blocks are
;; fontified by Emacs itself (htmlize) and emit CSS classes styled in
;; assets/styles.css; LaTeX fragments are rendered by MathJax, which
;; org includes only on pages that contain math.
;;
;; This file can also be loaded from an interactive session
;; (M-x load-file) to get the project definition, then publish with
;; C-c C-e P a inside any file under src/.

;;; Code:

(setq make-backup-files nil)

(defvar site-root
  (file-name-directory (or load-file-name buffer-file-name))
  "Root of the repository.")

;; --- Packages: self-contained install into .cache/packages ----------------

(require 'package)
(setq package-user-dir (expand-file-name ".cache/packages" site-root))
(setq package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(let ((missing (seq-remove #'package-installed-p '(htmlize rust-mode))))
  (when missing
    (package-refresh-contents)
    (mapc #'package-install missing)))

(require 'org)
(require 'ox-publish)
(require 'ox-html)
(require 'htmlize)
(require 'rust-mode)

;; --- Export settings -------------------------------------------------------

(setq org-export-with-smart-quotes t        ; “pretty” quotes, apostrophes
      org-export-with-sub-superscripts '{}  ; a_b stays literal, a_{b} subscripts
      org-export-with-section-numbers nil
      org-export-with-toc nil
      org-export-time-stamp-file nil
      org-export-global-macros
      '(("tag" . "@@html:<span class=\"tag\">$1</span>@@")
        ("date" . "@@html:<span class=\"entry-date\">$1</span>@@")
        ;; Inline logical formula; the argument stays outside the raw-HTML
        ;; snippets so org still processes x_{1} subscripts and entities.
        ("f" . "@@html:<span class=\"formula\">@@$1@@html:</span>@@")))

(setq org-html-doctype "html5"
      org-html-html5-fancy t
      org-html-divs '((preamble  "header" "site-header")
                      (content   "main"   "content")
                      (postamble "footer" "site-footer"))
      org-html-head-include-default-style nil
      org-html-head-include-scripts nil
      org-html-validation-link nil
      org-html-checkbox-type 'unicode
      ;; Emacs fontifies the code and emits class names (org-keyword,
      ;; org-string, ...) that assets/styles.css colors.
      org-html-htmlize-output-type 'css
      org-html-htmlize-font-prefix "org-"
      ;; Footnote definitions render as a closing "References" section.
      ;; ox-html passes (title definitions); %.0s consumes the stock title.
      org-html-footnotes-section
      "<div id=\"footnotes\">\n<h2 class=\"footnotes\">References%.0s</h2>\n<div id=\"text-footnotes\">\n%s\n</div>\n</div>")

(defvar site-html-head
  (concat
   "<meta name=\"author\" content=\"raventid\" />\n"
   "<link rel=\"icon\" type=\"image/png\" href=\"/assets/favicon.png\" />\n"
   "<link rel=\"stylesheet\" href=\"/assets/styles.css\" />"))

(defvar site-preamble
  "<nav>
  <a class=\"site-title\" href=\"/index.html\">raventid</a>
  <span class=\"site-links\">
    <a href=\"/index.html\">home</a>
    <a href=\"/about.html\">about</a>
    <a href=\"https://github.com/raventid\">github</a>
  </span>
</nav>")

(defvar site-postamble
  "<p>© 2026 raventid · woven in <a href=\"https://www.gnu.org/software/emacs/\">GNU Emacs</a> with <a href=\"https://orgmode.org\">org-mode</a></p>")

;; Keep the publish cache inside the repo, not in $HOME.
(setq org-publish-timestamp-directory
      (expand-file-name ".cache/org-timestamps/" site-root))

(setq org-publish-project-alist
      `(("pages"
         :base-directory ,(expand-file-name "src" site-root)
         :base-extension "org"
         :recursive t
         :publishing-directory ,site-root
         :publishing-function org-html-publish-to-html
         :html-head ,site-html-head
         :html-preamble ,site-preamble
         :html-postamble ,site-postamble
         :with-author nil
         :with-creator nil
         :with-date nil)
        ("site" :components ("pages"))))

(when noninteractive
  (org-publish "site" t)
  (message "Site published to %s" site-root))

;;; publish.el ends here
