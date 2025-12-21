package locationexpressions

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ExpressionsConstituentType int

const (
    ExpressionsConstituentTypeLayoutObjectClass ExpressionsConstituentType = 1
    ExpressionsConstituentTypeLayoutObject ExpressionsConstituentType = 2
    ExpressionsConstituentTypeContentPortion ExpressionsConstituentType = 3
    ExpressionsConstituentTypeLogicalObjectClass ExpressionsConstituentType = 5
    ExpressionsConstituentTypeLogicalObject ExpressionsConstituentType = 6
    ExpressionsConstituentTypePresentationStyle ExpressionsConstituentType = 7
    ExpressionsConstituentTypeLayoutStyle ExpressionsConstituentType = 8
    ExpressionsConstituentTypeSealedDocProfDescriptor ExpressionsConstituentType = 9
    ExpressionsConstituentTypeEncipheredDocProfDescriptor ExpressionsConstituentType = 10
    ExpressionsConstituentTypePreencipheredBodypartDescriptor ExpressionsConstituentType = 11
    ExpressionsConstituentTypePostencipheredBodypartDescriptor ExpressionsConstituentType = 12
    ExpressionsConstituentTypeLinkClass ExpressionsConstituentType = 13
    ExpressionsConstituentTypeLink ExpressionsConstituentType = 14
    ExpressionsConstituentTypeEncipheredLinkDescriptor ExpressionsConstituentType = 15
    ExpressionsConstituentTypeSubprofile ExpressionsConstituentType = 16
)

