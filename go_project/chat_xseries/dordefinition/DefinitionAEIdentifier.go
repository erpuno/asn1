package dordefinition

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionAEIdentifier struct {
    LocationalIdentifier DefinitionLocationalIdentifier `asn1:"optional,tag:0"`
    DirectLogicalIdentifier x500.InformationFrameworkDistinguishedName `asn1:"optional,tag:1"`
    IndirectLogicalIdentifier x500.InformationFrameworkDistinguishedName `asn1:"optional,tag:2"`
}
