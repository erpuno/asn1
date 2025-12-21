package pkix1implicit88

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88EDIPartyName struct {
    NameAssigner pkix1explicit88.PKIX1Explicit88DirectoryString `asn1:"optional,tag:0"`
    PartyName pkix1explicit88.PKIX1Explicit88DirectoryString `asn1:"tag:1"`
}
