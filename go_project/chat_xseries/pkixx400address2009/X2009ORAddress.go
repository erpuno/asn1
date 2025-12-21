package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ORAddress struct {
    BuiltInStandardAttributes X2009BuiltInStandardAttributes
    BuiltInDomainDefinedAttributes X2009BuiltInDomainDefinedAttributes `asn1:"optional"`
    ExtensionAttributes X2009ExtensionAttributes `asn1:"optional,set"`
}
