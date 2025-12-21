package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETFontAttributeSet struct {
    NamePrefixes []SETNamePrefix `asn1:"optional,set,tag:0"`
    IsoStandard9541Fontname SETGlobalName `asn1:"optional,tag:1"`
    IsoStandard9541Fontdescription SETFontDescription `asn1:"optional,tag:2"`
    IsoStandard9541Wrmodes SETWritingModes `asn1:"optional,tag:3"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:5"`
}
