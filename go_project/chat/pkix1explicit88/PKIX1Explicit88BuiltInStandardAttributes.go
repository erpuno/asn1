package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88BuiltInStandardAttributes struct {
    CountryName PKIX1Explicit88CountryName `asn1:"optional"`
    AdministrationDomainName PKIX1Explicit88AdministrationDomainName `asn1:"optional"`
    NetworkAddress PKIX1Explicit88NetworkAddress `asn1:"optional,tag:0"`
    TerminalIdentifier PKIX1Explicit88TerminalIdentifier `asn1:"optional,tag:1"`
    PrivateDomainName PKIX1Explicit88PrivateDomainName `asn1:"optional,tag:2"`
    OrganizationName PKIX1Explicit88OrganizationName `asn1:"optional,tag:3"`
    NumericUserIdentifier PKIX1Explicit88NumericUserIdentifier `asn1:"optional,tag:4"`
    PersonalName PKIX1Explicit88PersonalName `asn1:"optional,tag:5"`
    OrganizationalUnitNames PKIX1Explicit88OrganizationalUnitNames `asn1:"optional,tag:6"`
}
