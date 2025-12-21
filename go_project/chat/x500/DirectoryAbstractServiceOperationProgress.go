package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceOperationProgress struct {
    NameResolutionPhase int `asn1:"tag:0"`
    NextRDNToBeResolved int64 `asn1:"optional,tag:1"`
}
