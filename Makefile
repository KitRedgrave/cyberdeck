kitbook-home:
	RDE_TARGET=kitbook-home \
	guix home reconfigure -L . cyberdeck.scm

kitbook-system:
	RDE_TARGET=kitbook-system \
	guix system reconfigure -L . cyberdeck.scm

kithub-home:
	RDE_TARGET=kithub-home \
	guix home reconfigure -L . cyberdeck.scm

kithub-system:
	RDE_TARGET=kithub-system \
	guix system reconfigure -L . cyberdeck.scm
