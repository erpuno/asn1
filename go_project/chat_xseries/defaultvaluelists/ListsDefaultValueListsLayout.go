package defaultvaluelists

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ListsDefaultValueListsLayout struct {
    PageSetAttributes ListsPageSetAttributes `asn1:"optional,tag:1"`
    PageAttributes ListsPageAttributes `asn1:"optional,tag:2"`
    FrameAttributes ListsFrameAttributes `asn1:"optional,tag:3"`
    BlockAttributes ListsBlockAttributes `asn1:"optional,tag:4"`
}
