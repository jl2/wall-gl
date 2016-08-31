;;;; wall-gl.lisp
;;;;
;;;; Copyright (c) 2016 Jeremiah LaRocco <jeremiah.larocco@gmail.com>

(in-package #:wall-gl)

(named-readtables:in-readtable :qtools)

(declaim (optimize (speed 3) (safety 1) (size 1) (debug 1)))

(gl:define-gl-array-format position-color
  (gl:vertex :type :float :components (x y z))
  (gl:color :type :float :components (r g b)))

(defparameter *fps* 90)

(define-widget wall-animator (QGLWidget)
  ((x-rot :initform 0)
   (y-rot :initform 0)
   (z-rot :initform 0)
   (vertex-array :initform (gl:alloc-gl-array 'position-color 4))
   (indices-array :initform (gl:alloc-gl-array :unsigned-short 4)))
  (:documentation "3D wall visualization"))

(define-override (wall-animator close-event) (ev)
  (format t "Deleting arrays!~%")
  (gl:free-gl-array vertex-array)
  (gl:free-gl-array indices-array)
  (q+:accept ev))

(define-subwidget (wall-animator timer) (q+:make-qtimer wall-animator)
  (setf (q+:single-shot timer) nil))

(define-initializer (wall-animator setup)
  (q+:start timer (round (/ 1000 *fps*)))
  (setf (q+:auto-fill-background wall-animator) nil)
  (setf (q+:auto-buffer-swap wall-animator) nil))

(define-slot (wall-animator tick) ()
  (declare (connected timer (timeout)))
  (q+:repaint wall-animator))

(define-override (wall-animator initialize-G-L) ()
  (gl:enable :line-smooth :polygon-smooth
             :depth-test :depth-clamp :alpha-test)

  (setf (gl:glaref vertex-array 0 'x) -10.0)
  (setf (gl:glaref vertex-array 0 'y) -10.0)
  (setf (gl:glaref vertex-array 0 'z) 0.0)
  
  (setf (gl:glaref vertex-array 0 'r) 1.0)
  (setf (gl:glaref vertex-array 0 'g) 0.0)
  (setf (gl:glaref vertex-array 0 'b) 0.0)

  (setf (gl:glaref vertex-array 0 'x) -10.0)
  (setf (gl:glaref vertex-array 0 'y) 10.0)
  (setf (gl:glaref vertex-array 0 'z) 0.0)
  
  (setf (gl:glaref vertex-array 0 'r) 0.0)
  (setf (gl:glaref vertex-array 0 'g) 1.0)
  (setf (gl:glaref vertex-array 0 'b) 0.0)

  (setf (gl:glaref vertex-array 0 'x) 10.0)
  (setf (gl:glaref vertex-array 0 'y) 10.0)
  (setf (gl:glaref vertex-array 0 'z) 0.0)
  
  (setf (gl:glaref vertex-array 0 'r) 0.0)
  (setf (gl:glaref vertex-array 0 'g) 1.0)
  (setf (gl:glaref vertex-array 0 'b) 1.0)

  (setf (gl:glaref vertex-array 0 'x) 10.0)
  (setf (gl:glaref vertex-array 0 'y) -10.0)
  (setf (gl:glaref vertex-array 0 'z) 0.0)
  
  (setf (gl:glaref vertex-array 0 'r) 0.0)
  (setf (gl:glaref vertex-array 0 'g) 0.0)
  (setf (gl:glaref vertex-array 0 'b) 1.0)

  (setf (gl:glaref indices-array 0) 0)
  (setf (gl:glaref indices-array 1) 1)
  (setf (gl:glaref indices-array 2) 2)
  (setf (gl:glaref indices-array 3) 3)
)

(define-override (wall-animator resize-g-l) (width height)
  )


(define-override (wall-animator paint-g-l paint) ()
  "Handle paint events."
  (let* (
         (width (q+:width wall-animator))
         (height (q+:height wall-animator))
         (x-aspect-ratio (if (< height width)
                             (/ height width 1.0d0)
                             1.0d0))
         (y-aspect-ratio (if (< height width)
                             1.0d0
                             (/ width height 1.0d0))))

    (with-finalizing 
        ;; Create a painter object to draw on
        ((painter (q+:make-qpainter wall-animator)))

      (q+:begin-native-painting painter)

      (gl:viewport 0 0 width height)
      (gl:matrix-mode :projection)
      (gl:load-identity)

      (glu:perspective 50 (/ height width) 1.0 5000.0)
      (glu:look-at 60 60 60
                   0 0 0
                   0 1 0)

      (gl:clear-color 0 0 0 1)
      (gl:enable :line-smooth :polygon-smooth
                 :depth-test :depth-clamp :alpha-test)

      (gl:matrix-mode :modelview)
      (gl:load-identity)

      (gl:clear :color-buffer :depth-buffer)

      ;; Actual drawing goes here.  In this case, just a line.
      (gl:push-matrix)

      (gl:polygon-mode :front-and-back :line)
      
      (gl:rotate x-rot 1 0 0)
      (gl:rotate y-rot 0 1 0)
      (gl:rotate z-rot 0 0 1)

      (gl:enable-client-state :vertex-array)
      (gl:enable-client-state :color-array)
      
      (gl:bind-gl-vertex-array vertex-array)
      (gl:draw-elements :quads indices-array)
      ;; ;; TODO: Use "modern" OpenGL
      ;; (gl:with-primitives :quads
        
      ;;   (loop
      ;;      for i from -20 to 20
      ;;      do
      ;;        (loop for j from -20 to 20
      ;;           do
      ;;             (gl:color 1 0 0)
      ;;             (gl:vertex i j 0)
      ;;             (gl:vertex (+ i 1) j 0)

      ;;             (gl:color 0 1 0)
      ;;             (gl:vertex (+ i 1) (+ j 1) 0)
      ;;             (gl:vertex i (+ j 1) 0)

      ;;             )))
      (gl:pop-matrix)
      (q+:swap-buffers wall-animator)
      (q+:end-native-painting painter))))

(define-widget wall-widget (QWidget)
               ()
               (:documentation "A wall animator and its controls."))

(define-subwidget (wall-widget wall-viewer) (make-instance 'wall-animator)
  "The wall-animator itself.")


  
;; (define-subwidget (spirograph-widget a-val-spin) (q+:make-qdoublespinbox spirograph-widget)
;;   "The 'a' value spinbox."
;;   (q+:set-decimals a-val-spin 2)
;;   (q+:set-single-step a-val-spin 0.25)
;;   (q+:set-maximum a-val-spin 10000.0)
;;   (q+:set-minimum a-val-spin 0.0)
;;   (q+:set-value a-val-spin (animated-var-val (spirograph-a-var (slot-value fft-viewer 'spiro)))))


(define-subwidget (wall-widget x-rot-spin) (q+:make-qspinbox wall-widget)
  "The spinbox for the number of steps."
  (q+:set-maximum x-rot-spin 360)
  (q+:set-minimum x-rot-spin 0)
  (q+:set-value x-rot-spin 0))

(define-subwidget (wall-widget y-rot-spin) (q+:make-qspinbox wall-widget)
  "The spinbox for the number of steps."
  (q+:set-maximum y-rot-spin 360)
  (q+:set-minimum y-rot-spin 0)
  (q+:set-value y-rot-spin 0))

(define-subwidget (wall-widget z-rot-spin) (q+:make-qspinbox wall-widget)
  "The spinbox for the number of steps."
  (q+:set-maximum z-rot-spin 360)
  (q+:set-minimum z-rot-spin 0)
  (q+:set-value z-rot-spin 0))

(define-slot (wall-widget spinners-changed) ((value int))
  "Handle changes to the block-skip-spin box."
  (declare (connected x-rot-spin (value-changed int)))
  (declare (connected y-rot-spin (value-changed int)))
  (declare (connected z-rot-spin (value-changed int)))
  (with-slots (x-rot y-rot z-rot) wall-viewer
    (setf x-rot (q+:value x-rot-spin))
    (setf y-rot (q+:value y-rot-spin))
    (setf z-rot (q+:value z-rot-spin)))
  (q+:repaint wall-viewer))

(define-subwidget (wall-widget control-layout) (q+:make-qvboxlayout wall-widget)
  "Layout all of the control widgets in a vertical box layout."

  ;; Create horizontal layouts to hold the labels and spinboxes
  (let ((x-rot-layout (q+:make-qhboxlayout))
        (y-rot-layout (q+:make-qhboxlayout))
        (z-rot-layout (q+:make-qhboxlayout)))
    
    ;; Populate the horizontal layouts and add them to the top level vertical layout

    (q+:add-widget x-rot-layout (q+:make-qlabel "X Rotation: " wall-widget))
    (q+:add-widget x-rot-layout x-rot-spin)

    (q+:add-widget y-rot-layout (q+:make-qlabel "Y Rotation: " wall-widget))
    (q+:add-widget y-rot-layout y-rot-spin)

    (q+:add-widget z-rot-layout (q+:make-qlabel "Z Rotation: " wall-widget))
    (q+:add-widget z-rot-layout z-rot-spin)

    

    (q+:add-layout control-layout x-rot-layout)
    (q+:add-layout control-layout y-rot-layout)
    (q+:add-layout control-layout z-rot-layout)

    ;; Finally add the wall viewer directly to the vertical layout
    (q+:add-widget control-layout wall-viewer)))



(define-widget main-window (QMainWindow)
  ((mixer :initform (mixalot:create-mixer))
   (current-stream :initform nil)))

(define-override (main-window close-event) (ev)
  (mixalot:mixer-remove-all-streamers mixer)
  (mixalot:destroy-mixer mixer)
  (q+:accept ev))


(define-menu (main-window File)
  (:item ("Open MP3" (ctrl o))
         (format t "Doing nothing!~%"))
  (:separator)
  (:item ("Open Config" (ctrl i))
         (format t "Doing nothing!~%"))
  (:item ("Save Config" (ctrl s))
         (format t "Doing nothing!~%"))
  (:separator)
  (:item ("Quit" (ctrl alt q))
         (q+:close main-window)))

(define-menu (main-window Help)
  (:item "About"
         (q+:qmessagebox-information
          main-window "About"
          "Interactively view and manipulate FFT data.")))

(define-subwidget (main-window wall-viewer) (make-instance 'wall-widget)
  "The central wall-widget.")

(define-initializer (main-window setup)
  "Set the window title and set the fft-controls to be the central widget."
  (setf (q+:window-title main-window) "Interactive FFT Explorer")
  (setf (q+:central-widget main-window) wall-viewer))

(defun main ()
  "Create the main window."
  (trivial-main-thread:call-in-main-thread #'mixalot:main-thread-init)
  (with-main-window (window (make-instance 'main-window))))
