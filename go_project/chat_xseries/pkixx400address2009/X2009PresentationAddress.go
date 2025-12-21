package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PresentationAddress struct {
    PSelector []byte `asn1:"optional,tag:0,explicit"`
    SSelector []byte `asn1:"optional,tag:1,explicit"`
    TSelector []byte `asn1:"optional,tag:2,explicit"`
    NAddresses [][]byte `asn1:"set,tag:3,explicit"`
}
