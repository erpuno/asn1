package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009EncryptedValue struct {
    IntendedAlg asn1.RawValue `asn1:"optional,tag:0"`
    SymmAlg asn1.RawValue `asn1:"optional,tag:1"`
    EncSymmKey asn1.BitString `asn1:"optional,tag:2"`
    KeyAlg asn1.RawValue `asn1:"optional,tag:3"`
    ValueHint []byte `asn1:"optional,tag:4"`
    EncValue asn1.BitString
}
