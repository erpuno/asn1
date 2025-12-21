package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETGlyphProperties struct {
    IsoStandard9541Px SETRelRational `asn1:"optional,tag:0"`
    IsoStandard9541Py SETRelRational `asn1:"optional,tag:1"`
    IsoStandard9541Ex SETRelRational `asn1:"tag:2"`
    IsoStandard9541Ey SETRelRational `asn1:"tag:3"`
    IsoStandard9541Ext SETExtents `asn1:"tag:4"`
    IsoStandard9541Lgs SETLigatures `asn1:"optional,tag:5"`
    IsoStandard9541Peas SETPAdjusts `asn1:"optional,tag:6"`
    IsoStandard9541Cpeai SETCIndicator `asn1:"optional,tag:7"`
    IsoStandard9541Eai SETECode `asn1:"optional,tag:8"`
    IsoStandard9541Minex SETRelRational `asn1:"optional,tag:9"`
    IsoStandard9541Miney SETRelRational `asn1:"optional,tag:10"`
    IsoStandard9541Maxex SETRelRational `asn1:"optional,tag:11"`
    IsoStandard9541Maxey SETRelRational `asn1:"optional,tag:12"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:13"`
}
