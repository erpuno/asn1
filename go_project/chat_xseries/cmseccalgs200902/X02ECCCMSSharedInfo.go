package cmseccalgs200902

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X02ECCCMSSharedInfo struct {
    KeyInfo X02KeyWrapAlgorithm
    EntityUInfo []byte `asn1:"optional,tag:0,explicit"`
    SuppPubInfo []byte `asn1:"tag:2,explicit"`
}
