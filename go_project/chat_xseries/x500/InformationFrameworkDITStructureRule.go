package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkDITStructureRule struct {
    RuleIdentifier InformationFrameworkRuleIdentifier
    NameForm asn1.ObjectIdentifier
    SuperiorStructureRules []InformationFrameworkRuleIdentifier `asn1:"optional,set"`
}
