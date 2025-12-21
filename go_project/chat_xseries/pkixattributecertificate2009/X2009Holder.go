package pkixattributecertificate2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009Holder struct {
    BaseCertificateID asn1.RawValue `asn1:"optional,tag:0"`
    EntityName asn1.RawValue `asn1:"optional,tag:1"`
    ObjectDigestInfo X2009ObjectDigestInfo `asn1:"optional,tag:2"`
}
