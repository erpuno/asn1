package dordefinition

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionAlteredValue int

const (
    DefinitionAlteredValueValueNotAltered DefinitionAlteredValue = 1
    DefinitionAlteredValueValueAltered DefinitionAlteredValue = 2
    DefinitionAlteredValueUndefined DefinitionAlteredValue = 3
)

