package temporalrelationships

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type RelationshipsPresentationTime struct {
    Timing asn1.RawValue `asn1:"optional"`
    Duration asn1.RawValue `asn1:"optional"`
    Cyclic RelationshipsCyclic `asn1:"optional,tag:5"`
}
