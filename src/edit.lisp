(in-package :cl-mediawiki)

(defun check-edit-response (title xml)
  "Checks for the expected 'success' message
   signals match-errors assertion-errors and media-wiki-errors
  "
  (check-sxml-for-error xml)
  (let* ((kid (first
	       (find-nodes-by-name "edit" xml)))
	 (alist (second kid)))
    (unless alist
      (error 'media-wiki-error
	     :obj xml
	     :message "Couldnt find edit results"))
    (unless (string-equal "success" (sxml-attribute-value "result" alist))
      (error 'media-wiki-error
	     :message (format nil "Failed to Edit ~A : ~A "
			      title alist)
	     :code nil
	     :obj xml))))

(defun create-page
    (title text &key
	   (summary  "cl-mediawiki:create-page")
	   (override nil))
  "Creates a new wiki page
   If override is true, replace the existing page with the text passed in (if the page already exists)
  "
  (let* ((tokens (get-action-tokens title))
	 (parameters
	  (make-parameters
	   `((action edit)
	     (token ,(edit-token tokens))
	     (title ,title)
	     (basetimestamp ,(timestamp tokens))
	     ,(when (not override)
		  '(createonly  true))
	     (summary ,summary)
	     (text ,text)))
	   ))
      (check-edit-response
       title
       (parse-api-response-to-sxml (make-api-request parameters :method :post)))))

(defun add-new-page-section (title section-title section-text &key no-create)
  "Creates a new == section-title ==  at the bottom of the page. followed by the specified text"
  (let* ((tokens (get-action-tokens title))
	 (parameters
	  (make-parameters
	   `((action edit)
	     (token ,(edit-token tokens))
	     (title ,title)
	     (section new)
	     (summary ,section-title)
	     (basetimestamp ,(timestamp tokens))
	     ,(when no-create
		'(nocreate T))
	     (text ,section-text)))
	   ))
      (check-edit-response
       title
       (parse-api-response-to-sxml
	(make-api-request parameters :method :post)))
    ))

(defun append-text-to-page
    (title text &key
	   no-create
	   (summary  "cl-mediawiki:append-text-to-page"))
  "appends the text the the end of the page (will create the page if neccessary, unless no-create is passed)"
  (let* ((tokens (get-action-tokens title))
	 (parameters
	  (make-parameters
	   `((action edit)
	     (token ,(edit-token tokens))
	     (title ,title)
	     (summary ,summary)
	     (basetimestamp ,(timestamp tokens))
	     ,(when no-create
		'(nocreate T))
	     (appendtext ,text)))
	   ))
    (check-edit-response
     title
     (parse-api-response-to-sxml
      (make-api-request parameters :method :post)))
    ))

(defun prepend-text-to-page
    (title text &key
	   (summary  "cl-mediawiki:prepend-text-to-page")
	   no-create)
  "Adds the text to the beginning of the page named title
   (will create the page if neccessary unless no-create is true)"
  (let* ((tokens (get-action-tokens title)) 
	 (parameters
	  (make-parameters
	   `((action edit)
	     (token ,(edit-token tokens))
	     (title ,title)
	     (summary ,summary)
	     (basetimestamp ,(timestamp tokens))
	     ,(when no-create
		'(nocreate T))
	     (prependtext ,text)))
	   ))
    (check-edit-response
     title
     (parse-api-response-to-sxml
      (make-api-request parameters :method :post)))
    ))

(defun set-page-content
    (title text &key no-create
	   (summary  "cl-mediawiki:set-page-content"))
  "sets the text of a wiki page 'title' to the specified 'text',

     title: The wiki page to set the content of
     text: The new content that the wiki page should have
     no-create:, do not create the wiki page if it does not exist
     summary: The comment associated with changing the page content
    "
  (let* ((tokens (get-action-tokens title))
	 (parameters
	  (make-parameters
	   `((action edit)
	     (token ,(edit-token tokens))
	     (title ,title)
	     (summary ,summary)
	     (basetimestamp ,(timestamp tokens))
	     ,(when no-create
		'(nocreate T))
	     (text ,text)))
	   ))
    (check-edit-response
     title
     (parse-api-response-to-sxml
      (make-api-request parameters :method :post)))
    ))

#+cl-ppcre
(defun regex-replace-all (regex target-page replacement  &key default-content (summary "cl-mediawiki:regex-replace-all"))
  "Does a regex find/replace on the target page. If the page is empty, will set to default content if provided
    Works by calling get-content then regex-replacing on the content, then calling set-content "
  (let ((content (get-page-content target-page)))
    (set-page-content target-page 
     (if content
	 (cl-ppcre:regex-replace-all regex content replacement)
	 default-content)
     :no-create (null default-content)
     :summary summary)))




;; Copyright (c) 2008 Accelerated Data Works, Russ Tyndall

;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation files
;; (the "Software"), to deal in the Software without restriction,
;; including without limitation the rights to use, copy, modify, merge,
;; publish, distribute, sublicense, and/or sell copies of the Software,
;; and to permit persons to whom the Software is furnished to do so,
;; subject to the following conditions:

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
