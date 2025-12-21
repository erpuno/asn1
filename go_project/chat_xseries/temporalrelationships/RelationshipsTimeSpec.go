package temporalrelationships

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type RelationshipsTimeSpec struct {
    StartOffset int64 `asn1:"optional,tag:0"`
    EndOffset int64 `asn1:"optional,tag:1"`
    StartSeparation int64 `asn1:"optional,tag:2"`
    EndSeparation int64 `asn1:"optional,tag:3"`
}
