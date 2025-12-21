package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesPresentationAddress struct {
    PSelector []byte `asn1:"optional,tag:0"`
    SSelector []byte `asn1:"optional,tag:1"`
    TSelector []byte `asn1:"optional,tag:2"`
    NAddresses [][]byte `asn1:"set,tag:3"`
}
