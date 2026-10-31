# contracts/

The streaming wire contract: the event stream a transport produces for one
model segment, and the error codes it can carry. The SDK is part of the
`replit_ui` package; the protocol identifiers remain stable.

| File | What it defines |
|---|---|
| `sse-events.schema.json` | The SSE streaming protocol: six events, framing rules, ordering invariants |
| `error-codes.json` | The error-code registry with failure-class attribution |

These files are the specification, not a code generator's input. The Dart
types they describe are hand-written in
`packages/replit_ui/lib/src/ui_design/transport/`: `sse_events.dart` for the
event union and `error_codes.dart` for the registry. Nothing checks the two
against each other, so a change here means the matching change there, in the
same commit.

Evolution is additive: new event names, new optional fields, new error
codes. Decoders never throw on unknown events or fields.
