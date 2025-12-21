package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPResponseData struct {
    Version x500.AuthenticationFrameworkVersion `asn1:"tag:0,explicit"`
    ResponderID KEPResponderID
    ProducedAt time.Time
    Responses []KEPSingleResponse
    ResponseExtensions x500.AuthenticationFrameworkExtensions `asn1:"optional,tag:1,explicit"`
}
