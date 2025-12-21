package dordefinition

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DefinitionLocationalIdentifier struct {
    PresentationAddress x500.SelectedAttributeTypesPresentationAddress `asn1:"tag:0"`
    AeTitle DefinitionAETitle `asn1:"optional,tag:1"`
    ApplicationContexts []asn1.ObjectIdentifier `asn1:"set"`
}
