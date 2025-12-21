package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X42SchemeNumber int

const (
    X42SchemeNumberDhStaticSha1 X42SchemeNumber = 0
    X42SchemeNumberDhEphemSha1 X42SchemeNumber = 1
    X42SchemeNumberDhOneFlowSha1 X42SchemeNumber = 2
    X42SchemeNumberDhHybrid1Sha1 X42SchemeNumber = 3
    X42SchemeNumberDhHybrid2Sha1 X42SchemeNumber = 4
    X42SchemeNumberDhHybridOneFlowSha1 X42SchemeNumber = 5
    X42SchemeNumberMqv2Sha1 X42SchemeNumber = 6
    X42SchemeNumberMqv1Sha1 X42SchemeNumber = 7
)

