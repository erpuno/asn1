package dordefinition

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionQualityOfService struct {
    QoSLevel DefinitionQoSLevel `asn1:"tag:0"`
    UsageOfReference DefinitionSingleUseOfReference
}
