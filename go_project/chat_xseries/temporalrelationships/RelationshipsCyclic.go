package temporalrelationships

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type RelationshipsCyclic struct {
    NumberOfCycles asn1.RawValue `asn1:"tag:0"`
    CycleStartTime RelationshipsTimeDelay `asn1:"optional,tag:1"`
    CycleDuration RelationshipsIndefiniteOrTimeDelay `asn1:"optional,tag:2"`
}
