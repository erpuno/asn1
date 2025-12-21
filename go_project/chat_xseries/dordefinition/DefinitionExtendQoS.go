package dordefinition

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionExtendQoS struct {
    QoSLevel DefinitionRequestedQoSLevel `asn1:"optional,tag:0"`
    UsageOfReference DefinitionSingleUseOfReference `asn1:"optional"`
}
