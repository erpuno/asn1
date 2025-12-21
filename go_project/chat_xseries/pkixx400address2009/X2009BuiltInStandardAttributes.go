package pkixx400address2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009BuiltInStandardAttributes struct {
    CountryName X2009CountryName `asn1:"optional"`
    AdministrationDomainName X2009AdministrationDomainName `asn1:"optional"`
    NetworkAddress X2009NetworkAddress `asn1:"optional,tag:0"`
    TerminalIdentifier X2009TerminalIdentifier `asn1:"optional,tag:1"`
    PrivateDomainName X2009PrivateDomainName `asn1:"optional,tag:2"`
    OrganizationName X2009OrganizationName `asn1:"optional,tag:3"`
    NumericUserIdentifier X2009NumericUserIdentifier `asn1:"optional,tag:4"`
    PersonalName X2009PersonalName `asn1:"optional,tag:5"`
    OrganizationalUnitNames X2009OrganizationalUnitNames `asn1:"optional,tag:6"`
}
