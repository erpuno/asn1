package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETModalProperties struct {
    IsoStandard9541Nomescdir SETAngle `asn1:"optional,tag:0"`
    IsoStandard9541Escclass SETEscClassCode `asn1:"optional,tag:1"`
    IsoStandard9541Avgescx SETRelRational `asn1:"optional,tag:2"`
    IsoStandard9541Avgescy SETRelRational `asn1:"optional,tag:3"`
    IsoStandard9541Avglcescx SETRelRational `asn1:"optional,tag:4"`
    IsoStandard9541Avglcescy SETRelRational `asn1:"optional,tag:5"`
    IsoStandard9541Avgcapescx SETRelRational `asn1:"optional,tag:6"`
    IsoStandard9541Avgcapescy SETRelRational `asn1:"optional,tag:7"`
    IsoStandard9541Tabescx SETRelRational `asn1:"optional,tag:8"`
    IsoStandard9541Tabescy SETRelRational `asn1:"optional,tag:9"`
    IsoStandard9541Maxfontext SETMaxExtents `asn1:"optional,tag:10"`
    IsoStandard9541Sectors SETSectors `asn1:"optional,tag:11"`
    IsoStandard9541Escadjs []SETAdjusts `asn1:"optional,set,tag:12"`
    IsoStandard9541Minescadjsze SETRational `asn1:"optional,tag:13"`
    IsoStandard9541Maxescadjsze SETRational `asn1:"optional,tag:14"`
    IsoStandard9541Scores SETScores `asn1:"optional,tag:15"`
    IsoStandard9541Vscripts SETVariantScripts `asn1:"optional,tag:16"`
    IsoStandard9541Minlinesp SETAlignmentSpacing `asn1:"optional,tag:17"`
    IsoStandard9541Minanascale SETRational `asn1:"optional,tag:18"`
    IsoStandard9541Maxanascale SETRational `asn1:"optional,tag:19"`
    IsoStandard9541Nomalign SETGlobalName `asn1:"optional,tag:20"`
    IsoStandard9541Alignmodes SETAlignmentModes `asn1:"optional,tag:21"`
    IsoStandard9541Copyfits SETCopyfits `asn1:"optional,tag:22"`
    IsoStandard9541Dsnwordadd SETRelRational `asn1:"optional,tag:23"`
    IsoStandard9541Dsnwordampl SETRational `asn1:"optional,tag:24"`
    IsoStandard9541Minwordadd SETRelRational `asn1:"optional,tag:25"`
    IsoStandard9541Minwordampl SETRational `asn1:"optional,tag:26"`
    IsoStandard9541Maxwordadd SETRelRational `asn1:"optional,tag:27"`
    IsoStandard9541Maxwordampl SETRational `asn1:"optional,tag:28"`
    IsoStandard9541Dsnletteradd SETRelRational `asn1:"optional,tag:29"`
    IsoStandard9541Dsnletterampl SETRational `asn1:"optional,tag:30"`
    IsoStandard9541Minletteradd SETRelRational `asn1:"optional,tag:31"`
    IsoStandard9541Minletterampl SETRational `asn1:"optional,tag:32"`
    IsoStandard9541Maxletteradd SETRelRational `asn1:"optional,tag:33"`
    IsoStandard9541Maxletterampl SETRational `asn1:"optional,tag:34"`
    IsoStandard9541Glyphmetrics SETGlyphMetrics `asn1:"optional,tag:35"`
    NonIsoProperties SETPropertyList `asn1:"optional,set,tag:36"`
}
