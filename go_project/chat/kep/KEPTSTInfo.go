package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPTSTInfo struct {
    Version int64
    Policy KEPTSAPolicyId
    MessageImprint KEPMessageImprint
    SerialNumber int64
    GenTime time.Time
    Accuracy KEPAccuracy `asn1:"optional"`
    Nonce int64 `asn1:"optional"`
    Tsa KEPGeneralName `asn1:"optional,tag:0"`
    Extensions x500.AuthenticationFrameworkExtensions `asn1:"optional,tag:1"`
}
