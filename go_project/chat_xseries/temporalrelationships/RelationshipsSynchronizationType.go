package temporalrelationships

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type RelationshipsSynchronizationType int

const (
    RelationshipsSynchronizationTypeParallelLast RelationshipsSynchronizationType = 0
    RelationshipsSynchronizationTypeParallelFirst RelationshipsSynchronizationType = 1
    RelationshipsSynchronizationTypeParallelSelective RelationshipsSynchronizationType = 2
    RelationshipsSynchronizationTypeSequential RelationshipsSynchronizationType = 3
)

