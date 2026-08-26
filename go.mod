module github.com/pikasaco/pikasa-go

// Deliberately below the monorepo's own go directive. This module is
// consumed by other people's services, and a go line higher than they
// declare fails their build for nothing — the generated code needs
// none of it.
go 1.24.0

require (
	buf.build/gen/go/bufbuild/protovalidate/protocolbuffers/go v1.36.12-20260825204119-511051f7f437.1
	connectrpc.com/connect v1.19.1
	google.golang.org/protobuf v1.36.12
)
