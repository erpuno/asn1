package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLNewKeyAttributes struct {
    RekeyControlledByGLO bool `asn1:"optional,tag:0"`
    RecipientsNotMutuallyAware bool `asn1:"optional,tag:1"`
    Duration int64 `asn1:"optional,tag:2"`
    GenerationCounter int64 `asn1:"optional,tag:3"`
    RequestedAlgorithm X2009KeyWrapAlgorithm `asn1:"optional,tag:4"`
}
