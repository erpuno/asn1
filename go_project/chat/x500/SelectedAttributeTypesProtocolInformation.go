package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesProtocolInformation struct {
    NAddress []byte
    Profiles []asn1.ObjectIdentifier `asn1:"set"`
}
