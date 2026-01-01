# C99 ASN.1 Test Suite Makefile
# Links against the c99-asn1 library

CC = clang
CFLAGS = -Wall -Wextra -Wpedantic -std=c99 -O2
INCLUDES = -IParser/include -IGenerated
LDFLAGS = -LParser/build -lasn1

# Test executables
test_suite: test_suite.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS)

openssl_test: openssl_test.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS)

c99_client: c99_client.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS)

# Run tests
test: test_suite
	./test_suite

# Clean
clean:
	rm -f test_suite openssl_test

.PHONY: test clean test_suite openssl_test
