package basicaccesscontrol

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type BasicAccessControlProtectedItems struct {
    Entry asn1.RawValue `asn1:"optional,tag:0"`
    AllUserAttributeTypes asn1.RawValue `asn1:"optional,tag:1"`
    AttributeType []asn1.ObjectIdentifier `asn1:"optional,set,tag:2"`
    AllAttributeValues []asn1.ObjectIdentifier `asn1:"optional,set,tag:3"`
    AllUserAttributeTypesAndValues asn1.RawValue `asn1:"optional,tag:4"`
    AttributeValue []BasicAccessControlAttributeTypeAndValue `asn1:"optional,set,tag:5"`
    SelfValue []asn1.ObjectIdentifier `asn1:"optional,set,tag:6"`
    RangeOfValues x500.DirectoryAbstractServiceFilter `asn1:"optional,tag:7"`
    MaxValueCount []BasicAccessControlMaxValueCount `asn1:"optional,set,tag:8"`
    MaxImmSub int64 `asn1:"optional,tag:9"`
    RestrictedBy []BasicAccessControlRestrictedValue `asn1:"optional,set,tag:10"`
    Contexts []x500.InformationFrameworkContextAssertion `asn1:"optional,set,tag:11"`
    Classes x500.InformationFrameworkRefinement `asn1:"optional,tag:12"`
}
