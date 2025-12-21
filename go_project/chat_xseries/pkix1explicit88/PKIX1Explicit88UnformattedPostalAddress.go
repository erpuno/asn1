package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88UnformattedPostalAddress struct {
    PrintableAddress []string `asn1:"optional"`
    TeletexString asn1.RawValue `asn1:"optional"`
}
