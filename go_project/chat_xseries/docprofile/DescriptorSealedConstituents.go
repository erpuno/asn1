package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorSealedConstituents struct {
    ObjectClassIdentifiers []identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:0"`
    PresentationStyleIdentifiers []identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:1"`
    LayoutStyleIdentifiers []identifiersandexpressions.ExpressionsStyleIdentifier `asn1:"optional,tag:2"`
    ObjectIdentifiers []identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:3"`
}
