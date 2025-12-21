package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceEntryInformation struct {
    Name InformationFrameworkName
    FromEntry bool
    Information []asn1.RawValue `asn1:"optional,set"`
    IncompleteEntry bool `asn1:"tag:3"`
    PartialNameResolution bool `asn1:"tag:4"`
}
