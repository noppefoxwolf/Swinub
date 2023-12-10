# Swinub

Swinub is simple mastodon api library.

```swift
let authorization = ...
let request = GetV1TimelinesHome(authorization: authorization)
let (statuses, httpResponse) = try await URLSession.shared.response(request)
```
