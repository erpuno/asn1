package ldap

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type LDAPMessage struct {
    MessageID LDAPMessageID
    ProtocolOp asn1.RawValue
    Controls LDAPControls `asn1:"optional,tag:0"`
}
