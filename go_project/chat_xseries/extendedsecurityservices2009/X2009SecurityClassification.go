package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SecurityClassification int

const (
    X2009SecurityClassificationUnmarked X2009SecurityClassification = 0
    X2009SecurityClassificationUnclassified X2009SecurityClassification = 1
    X2009SecurityClassificationRestricted X2009SecurityClassification = 2
    X2009SecurityClassificationConfidential X2009SecurityClassification = 3
    X2009SecurityClassificationSecret X2009SecurityClassification = 4
    X2009SecurityClassificationTopSecret X2009SecurityClassification = 5
)

