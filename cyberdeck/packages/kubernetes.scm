;; blatantly stolen from https://codeberg.org/allana/guix-system
(define-module (cyberdeck packages kubernetes)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages node)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages version-control)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix build-system go)
  #:use-module ((guix licenses) #:prefix license:))

(define-public kops
  (package
    (name "kops")
    (version "1.22.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/kubernetes/kops")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1346w3hiidnk4w838ymp5lmq6v7r88h48m7bpmz3r3l8n9g41km9"))))
    (build-system go-build-system)
    (native-inputs `(("git" ,git)
		     ("gawk" ,gawk)
                     ("sed" ,sed)))
    (inputs `(("python" ,python)
	      ("perl" ,perl)
              ("ruby" ,ruby)
              ("node" ,node)))
    (arguments
     '(#:import-path "k8s.io/kops/cmd/kops"
       #:unpack-path "k8s.io/kops"
       #:install-source? #f
       #:tests? #f))
    (home-page "https://kops.sigs.k8s.io/")
    (synopsis "The easiest way to get a production grade Kubernetes
cluster up and running")
    (description
     "kops helps you create, destroy, upgrade and maintain
production-grade, highly available, Kubernetes clusters from the
command line. AWS (Amazon Web Services) is currently officially
supported, with GCE and OpenStack in beta support, and VMware vSphere
in alpha, and other platforms planned")
    (license license:asl2.0)))

(define-public go-k8s-io-kubernetes
  (package
   (name "go-k8s-io-kubernetes")
   (version "1.23.6")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/kubernetes/kubernetes")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0xvwdgypyhaszkrn8fa3sdlmy5fy1lx7hmh2s5n88fxkc2b950kr"))))
   (build-system go-build-system)
   (arguments
    `(#:import-path "k8s.io/kubernetes/kubernetes"
      #:tests? #f
      #:phases (modify-phases %standard-phases
		 ;; Source-only package
		 (delete 'build))))
   (home-page "https://github.com/kubernetes/kubernetes")
   (synopsis "Kubernetes")
   (description
    "Kubernetes is an open source system for managing
@url{https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/,containerized
applications} across multiple hosts; providing basic mechanisms for
deployment, maintenance, and scaling of applications.")
   (license license:asl2.0)))

(define-public kubeadm
  (package
   (inherit go-k8s-io-kubernetes)
   (name "kubeadm")
   (arguments
    '(#:unpack-path "k8s.io/kubernetes"
      #:import-path "k8s.io/kubernetes/cmd/kubeadm"
      #:install-source? #f
      #:phases (modify-phases %standard-phases
		 (delete 'install-license-files))))))

(define-public kubectl
  (package
   (inherit go-k8s-io-kubernetes)
   (name "kubectl")
   (native-inputs `(("bash" ,bash)))
   (arguments
    '(#:unpack-path "k8s.io/kubernetes"
      #:import-path "k8s.io/kubernetes/cmd/kubectl"  ;
      #:install-source? #f
      #:build-flags (list (string-append
		       "-ldflags=-s -w "
		       "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitCommit=ad3338546da947756e8a88aa6822e9c11e7eac22' "
		       "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitTreeState=clean' "
		       "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitVersion=v1.23.6' "
		       "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitMajor=1' "
		       "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitMinor=23'"))
      #:phases (modify-phases %standard-phases
		 (delete 'install-license-files))))))
