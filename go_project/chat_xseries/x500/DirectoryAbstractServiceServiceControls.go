package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceServiceControls struct {
    Options DirectoryAbstractServiceServiceControlOptions `asn1:"tag:0"`
    Priority int64 `asn1:"tag:1"`
    TimeLimit int64 `asn1:"optional,tag:2"`
    SizeLimit int64 `asn1:"optional,tag:3"`
    ScopeOfReferral int64 `asn1:"optional,tag:4"`
    AttributeSizeLimit int64 `asn1:"optional,tag:5"`
    ManageDSAITPlaneRef asn1.RawValue `asn1:"optional,tag:6"`
    ServiceType asn1.ObjectIdentifier `asn1:"optional,tag:7"`
    UserClass int64 `asn1:"optional,tag:8"`
}
