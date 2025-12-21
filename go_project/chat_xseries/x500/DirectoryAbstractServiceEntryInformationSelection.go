package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceEntryInformationSelection struct {
    Attributes asn1.RawValue
    InfoTypes int64 `asn1:"tag:2"`
    ExtraAttributes asn1.RawValue `asn1:"optional"`
    ContextSelection DirectoryAbstractServiceContextSelection `asn1:"optional"`
    ReturnContexts bool
    FamilyReturn DirectoryAbstractServiceFamilyReturn
}
