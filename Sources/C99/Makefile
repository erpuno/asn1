# C99 ASN.1 Test Suite Makefile
# Links against the c99-asn1 library

CC = clang
CFLAGS = -Wall -Wextra -Wpedantic -std=c99 -O2
INCLUDES = -I../../c99-asn1/include
LDFLAGS = -L../../c99-asn1/build -lasn1

# Test executable
test_suite: test_suite.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS)

# Run tests
test: test_suite
	./test_suite

# Clean
clean:
	rm -f test_suite

.PHONY: test clean
