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

## Versioning

This module is generated from the pikasa monorepo's `protos/` and is
published from it; do not edit the files here. Regenerate with
`make sdk/build` in that repo.
