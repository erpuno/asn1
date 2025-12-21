package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X42OtherInfo struct {
    KeyInfo asn1.RawValue
    PartyUInfo []byte `asn1:"optional,tag:0"`
    PartyVInfo []byte `asn1:"optional,tag:1"`
    SuppPubInfo []byte `asn1:"optional,tag:2"`
    SuppPrivInfo []byte `asn1:"optional,tag:3"`
}
