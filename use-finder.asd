(cl:in-package #:asdf-user)

(defsystem use-finder
  :depends-on (:use-finder-reader :trivial-gray-streams :unix-opts :uiop)
  :serial t
  :components
  ((:file "packages")
   (:file "stream")
   (:file "reader-programming")
   (:file "use-finder")))
