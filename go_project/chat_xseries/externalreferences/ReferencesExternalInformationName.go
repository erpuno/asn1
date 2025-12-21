package externalreferences

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ReferencesExternalInformationName struct {
    String string `asn1:"tag:0"`
    ObjectId asn1.ObjectIdentifier `asn1:"optional,tag:1"`
}
