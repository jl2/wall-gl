;;;; wall-gl.asd
;;;;
;;;; Copyright (c) 2016 Jeremiah LaRocco <jeremiah.larocco@gmail.com>

(asdf:defsystem #:wall-gl
  :description "Describe wall-gl here"
  :author "Jeremiah LaRocco <jeremiah.larocco@gmail.com>"
  :license "ISC (BSD-like)"
  :depends-on (#:qt
               #:qtools
               #:qtgui
               #:qtcore
               #:anim-utils
               #:mixalot-mp3
               #:qtopengl
               #:cl-opengl
               #:cl-glu
               #:trivial-main-thread)
  :serial t
  :components ((:file "package")
               (:file "wall-gl")))

