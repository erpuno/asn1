package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkAttributeTypeAndDistinguishedValue struct {
    Type asn1.ObjectIdentifier
    Value asn1.RawValue
    PrimaryDistinguished bool
    ValuesWithContext []asn1.RawValue `asn1:"optional,set"`
}
