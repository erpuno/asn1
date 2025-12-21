package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkRequestAttribute struct {
    AttributeType asn1.ObjectIdentifier
    IncludeSubtypes bool `asn1:"tag:0"`
    SelectedValues []asn1.RawValue `asn1:"optional,tag:1"`
    DefaultValues []asn1.RawValue `asn1:"optional,tag:2"`
    Contexts []InformationFrameworkContextProfile `asn1:"optional,tag:3"`
    ContextCombination InformationFrameworkContextCombination `asn1:"tag:4"`
    MatchingUse []InformationFrameworkMatchingUse `asn1:"optional,tag:5"`
}
