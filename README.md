# pikasa Go SDK

Generated Connect/protobuf clients for the public pikasa API.

```bash
go get github.com/pikasaco/pikasa-go
```

## What's here

| Package | API |
| --- | --- |
| `pikasa/integrators/v1` | Publish listings — API-key authenticated. This is what a CRM integrates against. |
| `pikasa/listings/v1` | Public listing search and read, plus the shared value types. |
| `pikasa/insights/v1` | Public market statistics. |
| `pikasa/leads/v1` | Public lead capture. |
| `pikasa/discovery/v1` | Property discovery across the wider market — API-key authenticated. |

The consumer-account API is deliberately absent: it serves pikasa's own
portal and is not built to support third-party use.

## Base URL

```
https://api.pikasa.co/grpc
```

The `/grpc` suffix is required — the services are mounted under it, so a
client built with the bare host returns 404 on every call.

## Publishing a listing

```go
import (
	"connectrpc.com/connect"
	integratorsv1 "github.com/pikasaco/pikasa-go/pikasa/integrators/v1"
	"github.com/pikasaco/pikasa-go/pikasa/integrators/v1/integratorsv1connect"
	listingsv1 "github.com/pikasaco/pikasa-go/pikasa/listings/v1"
)

// Note the /grpc suffix — every service is mounted under it. Without it
// each call returns 404.
client := integratorsv1connect.NewIntegratorServiceClient(httpClient, "https://api.pikasa.co/grpc")

req := connect.NewRequest(&integratorsv1.UpsertListingRequest{
	ExternalId:             "your-crm-id-123",
	OrganizationExternalId: "your-agency-id",
	Title:                  "Apartamento en Ciudad Jardín",
	TransactionType:        listingsv1.TransactionType_TRANSACTION_TYPE_RENT,
	// ...
})
req.Header().Set("Authorization", "Bearer "+apiKey)

resp, err := client.UpsertListing(ctx, req)
```

Upserts are keyed by `external_id`: full-replace and idempotent, so
re-sending a listing is safe and is how you update one. Removal goes
through `RemoveListing`, not a status change.

An organization must be upserted before any listing that references it.

## Discovering properties

Discovery is a search engine for real estate: it finds properties across the
wider market, not only those published on pikasa. Each result carries a
`Source` — the page where the property is published — and that is where a
result should link. Results are not pikasa listings and have no public id.

```go
import (
	"connectrpc.com/connect"
	discoveryv1 "github.com/pikasaco/pikasa-go/pikasa/discovery/v1"
	"github.com/pikasaco/pikasa-go/pikasa/discovery/v1/discoveryv1connect"
	listingsv1 "github.com/pikasaco/pikasa-go/pikasa/listings/v1"
)

client := discoveryv1connect.NewDiscoveryServiceClient(httpClient, "https://api.pikasa.co/grpc")

req := connect.NewRequest(&discoveryv1.DiscoverRequest{
	CountryCode:     "CO",
	Admin2:          "medellin", // case and accents are ignored
	TransactionType: listingsv1.TransactionType_TRANSACTION_TYPE_RENT,
	PropertyTypes: []listingsv1.PropertyType{ // any of these; empty = any
		listingsv1.PropertyType_PROPERTY_TYPE_HOUSE,
		listingsv1.PropertyType_PROPERTY_TYPE_APARTMENT,
	},
	MaxPrice: 4_000_000,
	PageSize:        20,
})
req.Header().Set("Authorization", "Bearer "+apiKey)

resp, err := client.Discover(ctx, req)
for _, r := range resp.Msg.Results {
	fmt.Println(r.Title, r.RentPrice.GetAmount(), r.Source.Url)
}
// Next page: set PageToken to resp.Msg.NextPageToken; empty means the end.
```

A price range needs a transaction type of `SALE` or `RENT` — a sale price and
a monthly rent are not on one scale — and is rejected otherwise.

`SearchListings` takes the same `PropertyTypes` list. Its older single
`PropertyType` field is deprecated but still honoured, merged into the list.

### Searching a radius

Both `Discover` and `SearchListings` take `Near` — a point and a radius in
metres, up to 50 km. Results then come back nearest first, each with
`DistanceM` set; a radius cannot be combined with `Bbox`.

```go
Near: &listingsv1.Near{Lat: 6.2087, Lon: -75.5680, RadiusM: 1500},
```

## Versioning

This module is generated from the pikasa monorepo's `protos/` and is
published from it; do not edit the files here. Regenerate with
`make sdk/build` in that repo.
