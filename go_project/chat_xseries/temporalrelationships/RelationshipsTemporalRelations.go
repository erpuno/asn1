package temporalrelationships

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type RelationshipsTemporalRelations struct {
    SynchronizationType RelationshipsSynchronizationType `asn1:"tag:0"`
    SubordinateNodes []asn1.RawValue `asn1:"tag:1"`
}
