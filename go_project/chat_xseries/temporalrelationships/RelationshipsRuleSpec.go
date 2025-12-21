package temporalrelationships

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type RelationshipsRuleSpec struct {
    MinimumDuration int64 `asn1:"optional,tag:0"`
    MaximumDuration int64 `asn1:"optional,tag:1"`
}
