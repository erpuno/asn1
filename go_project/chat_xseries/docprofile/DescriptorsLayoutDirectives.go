package docprofile

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/identifiersandexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsLayoutDirectives struct {
    Indivisibility asn1.RawValue `asn1:"optional"`
    Separation DescriptorsSeparation `asn1:"optional,tag:3"`
    Offset DescriptorsOffset `asn1:"optional,tag:4"`
    FillOrder DescriptorsFillOrder `asn1:"optional,tag:5"`
    Concatenation DescriptorsConcatenation `asn1:"optional,tag:6"`
    NewLayoutObject asn1.RawValue `asn1:"optional"`
    SameLayoutObject DescriptorsSameLayoutObject `asn1:"optional,tag:10"`
    LayoutObjectClass identifiersandexpressions.ExpressionsObjectOrClassIdentifier `asn1:"optional,tag:11"`
    LogicalStreamCategory identifiersandexpressions.ExpressionsCategoryName `asn1:"optional,tag:19"`
    LogicalStreamSubCategory identifiersandexpressions.ExpressionsCategoryName `asn1:"optional,tag:20"`
    LayoutCategory identifiersandexpressions.ExpressionsCategoryName `asn1:"optional,tag:12"`
    Synchronization asn1.RawValue `asn1:"optional"`
    BlockAlignment DescriptorsBlockAlignment `asn1:"optional,tag:14"`
    FloatabilityRange DescriptorsFloatabilityRange `asn1:"optional,tag:24"`
}
