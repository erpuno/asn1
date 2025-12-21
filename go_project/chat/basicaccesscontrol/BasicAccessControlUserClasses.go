package basicaccesscontrol

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type BasicAccessControlUserClasses struct {
    AllUsers asn1.RawValue `asn1:"optional,tag:0"`
    ThisEntry asn1.RawValue `asn1:"optional,tag:1"`
    Name []x500.SelectedAttributeTypesNameAndOptionalUID `asn1:"optional,set,tag:2"`
    UserGroup []x500.SelectedAttributeTypesNameAndOptionalUID `asn1:"optional,set,tag:3"`
    Subtree []x500.InformationFrameworkSubtreeSpecification `asn1:"optional,set,tag:4"`
}
