(cl:in-package #:use-finder)

(defun use-finder (input-filespec output-filespec)
  (with-open-stream (input-stream input-filespec)
    (with-open-file (output-stream output-filespec
                                   :direction :output
                                   :if-does-not-exist :create
                                   :if-exists :supersede)
      (format output-stream
              "-*- mode: compilation; default-directory: \"~a\" -*-~%~%"
              (directory-namestring (first (directory "."))))
      (let ((*package* *package*)
            (*output-stream* output-stream)
            (*input-filename* input-filespec))
        (loop for expression = (sicl-reader:read input-stream nil nil nil)
              when (null expression)
                return nil
              when (and (consp expression)
                        (eq (first expression) 'cl:in-package))
                do (setf *package* (find-package (second expression))))))))

(opts:define-opts
  (:name :in
         :description "Input file"
         :short #\i
         :long "in"
         :arg-parser #'identity)
  (:name :out
         :description "Output file"
         :short #\o
         :long "out"
         :arg-parser #'identity)
  (:name :emacs-mode-line
         :description "Include Emacs mode line in output"
         :short #\e
         :long "emacs-mode-line")  
  (:name :help
         :description "Print help text"
         :short #\h
         :long "help"))

(defun display-usage ()
  (opts:describe :prefix "Find non-prefixed symbols in a Lisp file"))

(defmacro with-open-stream-or-default ((sym create-p create-stream-form default-stream) &body body)
  (let ((fn-sym (gensym))
        (stream-sym (gensym)))
    `(flet ((,fn-sym (,sym)
              ,@body))
       (if ,create-p
           (with-open-stream (,stream-sym ,create-stream-form)
             (,fn-sym ,stream-sym))
           (,fn-sym ,default-stream)))))

(defun main ()
  (multiple-value-bind (options free-args)
      (handler-case
          (opts:get-opts)
        (opts:missing-arg (condition)
          (format *error-output* "Error: option ~s needs an argument~%~%"
                  (opts:option condition))
          (display-usage)
          (uiop:quit 1))
        (opts:arg-parser-failed (condition)
          (format *error-output* "Error: can't parse ~s as argument of ~s~%~%"
                  (opts:raw-arg condition) (opts:option condition))
          (display-usage)
          (uiop:quit 1)))
    (when (or free-args (getf options :help))
      (display-usage)
      (uiop:quit 0))
    (let ((option-in (getf options :in))
          (option-out (getf options :out)))
      (unless option-in
        (format *error-output* "Input filename not specified~%")
        (uiop:quit 1))
      (with-open-file (input-stream option-in)
        (with-open-stream-or-default (output-stream option-out
                                                    (open option-out :direction :output
                                                                     :if-does-not-exist :create
                                                                     :if-exists :supersede)
                                                    *standard-output*)
          (when (getf options :emacs-mode-line)
            (format output-stream
                    "-*- mode: compilation; default-directory: \"~a\" -*-~%~%"
                    (directory-namestring (first (directory ".")))))
          (let ((*package* *package*)
                (*output-stream* output-stream)
                (*input-filename* option-in))
            (loop for expression = (sicl-reader:read input-stream nil nil nil)
                  when (null expression)
                    return nil
                  when (and (consp expression)
                            (eq (first expression) 'cl:in-package))
                    do (setf *package* (find-package (second expression))))))))))
