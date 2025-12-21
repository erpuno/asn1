package geogrpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesASFType int

const (
    AttributesASFTypeBundled AttributesASFType = 0
    AttributesASFTypeIndividual AttributesASFType = 1
)

