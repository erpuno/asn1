package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETFontDescription struct {
    IsoStandard9541Dataversion SETDataVersion `asn1:"optional,tag:0"`
    IsoStandard9541Standardversion SETCardinal `asn1:"optional,tag:1"`
    IsoStandard9541Datasource SETGlobalName `asn1:"optional,tag:2"`
    IsoStandard9541Datacopyright SETMessage `asn1:"optional,tag:3"`
    IsoStandard9541Dsnsource SETGlobalName `asn1:"optional,tag:4"`
    IsoStandard9541Dsncopyright SETMessage `asn1:"optional,tag:5"`
    IsoStandard9541Relunits SETCardinal `asn1:"tag:6"`
    IsoStandard9541Typeface SETMessage `asn1:"optional,tag:7"`
    IsoStandard9541Fontfamily SETMatchString `asn1:"optional,tag:8"`
    IsoStandard9541Posture SETPostureCode `asn1:"optional,tag:9"`
    IsoStandard9541Postureangle SETAngle `asn1:"optional,tag:10"`
    IsoStandard9541Weight SETWeightCode `asn1:"optional,tag:11"`
    IsoStandard9541Propwidth SETWidthCode `asn1:"optional,tag:12"`
    IsoStandard9541Glyphcomp SETGlyphComplement `asn1:"optional,tag:13"`
    IsoStandard9541Nomwrmode SETGlobalName `asn1:"optional,tag:14"`
    IsoStandard9541Dsnsize SETRational `asn1:"optional,tag:15"`
    IsoStandard9541Minsize SETRational `asn1:"optional,tag:16"`
    IsoStandard9541Maxsize SETRational `asn1:"optional,tag:17"`
    IsoStandard9541Capheight SETRelRational `asn1:"optional,tag:18"`
    IsoStandard9541Lcheight SETRelRational `asn1:"optional,tag:19"`
    IsoStandard9541Dsngroup SETDesignGroup `asn1:"optional,tag:20"`
    IsoStandard9541Structure SETStructureCode `asn1:"optional,tag:21"`
    IsoStandard9541Minfeatsz SETRelRational `asn1:"optional,tag:22"`
    IsoStandard9541Nomcapstemwidth SETRelRational `asn1:"optional,tag:23"`
    IsoStandard9541Nomlcstemwidth SETRelRational `asn1:"optional,tag:24"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:25"`
}
