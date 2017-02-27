(cl:in-package #:asdf-user)

(defsystem :use-finder-reader
  :depends-on (:alexandria)
  :serial t
  :components
  ((:file "packages")
   (:file "more-variables")
   (:file "additional-conditions")
   (:file "readtable")
   (:file "utilities")
   (:file "tokens")
   (:file "read-common")
   (:file "read")
   (:file "macro-functions")
   (:file "init")
   (:file "quasiquote-macro")))
