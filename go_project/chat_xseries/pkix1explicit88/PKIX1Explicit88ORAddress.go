package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88ORAddress struct {
    BuiltInStandardAttributes PKIX1Explicit88BuiltInStandardAttributes
    BuiltInDomainDefinedAttributes PKIX1Explicit88BuiltInDomainDefinedAttributes `asn1:"optional"`
    ExtensionAttributes PKIX1Explicit88ExtensionAttributes `asn1:"optional,set"`
}
