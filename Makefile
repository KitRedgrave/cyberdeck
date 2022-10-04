home:
	RDE_TARGET=kitbook-home \
	guix home reconfigure -L . cyberdeck.scm

system:
	RDE_TARGET=kitbook-system \
	guix system reconfigure -L . cyberdeck.scm
