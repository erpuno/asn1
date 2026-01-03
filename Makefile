clean:
	@echo "Cleaning project..."
	@scripts/clean.sh

rebuild-c99:
	@scripts/rebuild_c99.sh

rebuild-go:
	@scripts/rebuild_go.sh

rebuild-java:
	@scripts/rebuild_java.sh

rebuild-rust:
	@scripts/rebuild_rust.sh

rebuild-swift:
	@scripts/rebuild_swift.sh

rebuild-ts:
	@scripts/rebuild_ts.sh

verify-c99:
	@scripts/verify_c99.sh

verify-go:
	@scripts/verify_go.sh

verify-java:
	@scripts/verify_java.sh

verify-rust:
	@scripts/verify_rust.sh

verify-swift:
	@scripts/verify_swift.sh

verify-ts:
	@scripts/verify_ts.sh

verify-all: verify-c99 verify-go verify-java verify-rust verify-swift verify-ts

# OpenSSL Test Targets
test-c99:
	@scripts/run_c99_openssl_tests.sh

test-go:
	@scripts/run_go_openssl_tests.sh

test-java:
	@scripts/run_java_openssl_tests.sh

test-rust:
	@scripts/run_rust_openssl_tests.sh

test-swift:
	@scripts/run_swift_openssl_tests.sh

test-ts:
	@scripts/run_ts_openssl_tests.sh

test-all: test-c99 test-go test-java test-rust test-swift test-ts
