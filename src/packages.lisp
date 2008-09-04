;; -*- lisp -*-

(defpackage :net.acceleration.cl-mediawiki
    (:use :common-lisp :iterate)
  (:nicknames :cl-mediawiki)
  (:export
   ;; query
   #:get-page-content
   #:get-action-tokens
   ;; EDIT
   #:set-page-content
   #:append-text-to-page
   #:add-new-page-section
   #:create-page
   ))