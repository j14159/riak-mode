;; First real crack at learning elisp.  Many horrors herein,
;; including but not limited to mutating global variables.

;; Obviously no warranty, use at your own risk and don't piss off 
;; your ops team by running this against production.

;; This code does most things that the Riak documentation tells you NOT
;; to do, including listing buckets and keys within buckets.  Probably
;; not a good idea to run this against your production cluster.

;; Get emacs-web from melpa/marmalade/whatever.
(require 'web)

;; you'll be prompted for this at mode start:
(defvar riak-host "starting-this-mode-will-prompt-for-this")
(defvar riak-mode-riak-port "8098")

(defvar riak-mode-hook nil)
(defvar riak-mode-map
  (let ((map (make-keymap)))
    (suppress-keymap map t)
    (define-key map (kbd "b") 'riak-mode-list-buckets)
    (define-key map (kbd "RET") 'riak-mode-handle-select)
    map)
  "Keymap for riak-mode")

;; this bothers me quite a bit, should likely be some parameter
;; of a different buffer for the display of keys:
(defvar riak-mode-current-bucket "")

;; as with the keys buffer above, I suspect I'd be much better
;; served by simply allocating a buffer for the bucket listing
;; than doing this:
(defvar riak-mode-bucket-vec [])

(defun riak-mode-list-buckets () 
  "Convenience to wrap fetching buckets and the cached vector of them."
  (interactive) 
  (if (string= riak-mode-current-bucket "")
      (get-riak-buckets riak-host)
    (display-buckets riak-mode-bucket-vec)))

(defun riak-mode-handle-select ()
  "Handle whether we're selecting a bucket or fetching keys or a key itself"
  (interactive)
  (if (string= riak-mode-current-bucket "")
      (let ((bucket (line-at-cursor)))
        (setq riak-mode-current-bucket bucket)
        (message (concat "Bucket is now " riak-mode-current-bucket))
        (get-riak-keys riak-host bucket))
    (let ((key (line-at-cursor)))
      (get-key riak-host riak-mode-current-bucket key))))


(defun output-buffer () 
  "Common handle to our output buffer"
  (get-buffer-create "*riak-mode-output*"))

(defun get-riak-buckets (host)
  "Fetch buckets from Riak, parse them and display them"
  (message "getting buckets, please wait")
  (web-http-get
   (lambda (con header data)
     (display-buckets (parse-buckets data)))
   :url (concat "http://" host ":" riak-mode-riak-port "/buckets?buckets=true")))

(defun get-riak-keys (host bucket)
  "Fetch keys for the given bucket"
  (message (concat "getting keys for " bucket))
  (web-http-get
   (lambda (con header data)
     (display-keys data))
   :url (concat "http://" host ":" riak-mode-riak-port "/buckets/" bucket "/keys?keys=true")))

(defun get-key (host bucket key)
  "Get a specific key from the given bucket"
  (web-http-get
   (lambda (con headers data)
     (with-current-buffer (output-buffer)
       (erase-buffer)
       (insert data)))
   :url (concat "http://" host ":" riak-mode-riak-port "/riak/" bucket "/" key)))

(defun display-keys (json-body)
  "Parse and display the keys in the JSON body."
  (with-current-buffer (output-buffer)
    (let ((bucket-keys
           (cdr (assoc 'keys (json-read-from-string json-body)))))
      (erase-buffer)
      (mapcar (lambda (k) (insert (concat k "\n"))) bucket-keys))))

(defun parse-buckets (json-body) 
  "Parse the given bucket list JSON.  Side effect of caching the buckets, gross."
  (let ((b (cdr (assoc 'buckets
              (json-read-from-string json-body)))))
    (setq riak-mode-bucket-vec b)
    b))

(defun display-buckets (b)
  "Display the vector of buckets."
  (with-current-buffer (output-buffer)
    (erase-buffer)
    (setq riak-mode-current-bucket "")
    (mapcar (lambda (buck) (insert (concat buck "\n"))) b)))

(defun line-at-cursor ()
  "Simple convenience function to grab the line under the cursor minus the newline char"
  (replace-regexp-in-string "\n$" "" (thing-at-point 'line)))

(defun riak-mode ()
  (switch-to-buffer (output-buffer))
  (interactive)
  (kill-all-local-variables)
  (let ((riak-node (read-from-minibuffer "Riak node to use:  ")))
    (setq riak-host riak-node))
  (use-local-map riak-mode-map)
  (setq major-mode 'riak-mode)
  (setq mode-name "RiakMode")
  (run-hooks 'riak-mode-hook))

(provide 'riak-mode)
