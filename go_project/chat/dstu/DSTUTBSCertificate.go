package dstu

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DSTUTBSCertificate struct {
    Version DSTUVersion `asn1:"tag:0,explicit"`
    SerialNumber DSTUCertificateSerialNumber
    Signature asn1.RawValue
    Issuer DSTUName
    Validity DSTUValidity
    Subject DSTUName
    SubjectPublicKeyInfo asn1.RawValue
    IssuerUniqueID DSTUUniqueIdentifier `asn1:"optional,tag:1"`
    SubjectUniqueID DSTUUniqueIdentifier `asn1:"optional,tag:2"`
    Extensions DSTUExtensions `asn1:"optional,tag:3,explicit"`
}
