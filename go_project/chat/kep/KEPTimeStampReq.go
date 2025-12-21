package kep

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/x500"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type KEPTimeStampReq struct {
    Version int64
    MessageImprint KEPMessageImprint
    ReqPolicy KEPTSAPolicyId `asn1:"optional"`
    Nonce int64 `asn1:"optional"`
    CertReq bool
    Extensions x500.AuthenticationFrameworkExtensions `asn1:"optional,tag:0"`
}
