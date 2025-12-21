package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkImposedSubset int

const (
    InformationFrameworkImposedSubsetBaseObject InformationFrameworkImposedSubset = 0
    InformationFrameworkImposedSubsetOneLevel InformationFrameworkImposedSubset = 1
    InformationFrameworkImposedSubsetWholeSubtree InformationFrameworkImposedSubset = 2
)

