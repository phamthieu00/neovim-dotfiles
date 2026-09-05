.PHONY: install uninstall doctor test update

install:
	./scripts/install.sh

uninstall:
	./scripts/uninstall.sh

doctor:
	./scripts/doctor.sh

test:
	./tests/smoke-test.sh

update:
	./scripts/update.sh
