package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesZonalResult int

const (
    SelectedAttributeTypesZonalResultCannotSelectMapping SelectedAttributeTypesZonalResult = 0
    SelectedAttributeTypesZonalResultZeroMappings SelectedAttributeTypesZonalResult = 2
    SelectedAttributeTypesZonalResultMultipleMappings SelectedAttributeTypesZonalResult = 3
)

