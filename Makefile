.PHONY: test
test:
	-shellcheck realpath.sh
	-checkbashisms realpath.sh
	"$(SHELL)" t/test_resolve_symlinks
	"$(SHELL)" t/test_canonicalize_path
	"$(SHELL)" t/test_realpath_integration
