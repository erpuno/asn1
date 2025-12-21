package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceCommonResultsSeq struct {
    SecurityParameters DirectoryAbstractServiceSecurityParameters `asn1:"optional,tag:30"`
    Performer InformationFrameworkDistinguishedName `asn1:"optional,tag:29"`
    AliasDereferenced bool `asn1:"tag:28"`
}
