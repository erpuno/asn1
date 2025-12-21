package externalreferences

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/locationexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ReferencesExternalReferencesListElement struct {
    ReferenceName ReferencesReferenceName `asn1:"tag:1"`
    ExternalEntity ReferencesExternalEntity `asn1:"tag:2"`
    LocationRule locationexpressions.ExpressionsLocationExpression `asn1:"optional,tag:3"`
}
