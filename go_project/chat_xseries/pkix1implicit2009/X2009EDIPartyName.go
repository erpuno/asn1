package pkix1implicit2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009EDIPartyName struct {
    NameAssigner asn1.RawValue `asn1:"optional,tag:0"`
    PartyName asn1.RawValue `asn1:"tag:1"`
}
