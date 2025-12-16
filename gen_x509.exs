
# Load the compiler module
Code.require_file("asn1.ex", ".")

# Set up environment variables for the compilation
# Target ONLY the AuthenticationFramework file
File.mkdir_p!("Sources/Suite/XSeries")
Application.put_env(:asn1scg, "output", "Sources/Suite/XSeries/")

# Compile only AuthenticationFramework.asn1
ASN1.compile(true, "priv/x-series/AuthenticationFramework.asn1")
