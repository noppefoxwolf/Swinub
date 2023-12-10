# Swinub

Swinub is simple mastodon api library.

```swift
let authorization = ...
let request = GetV1TimelinesHome(authorization: authorization)
let (statuses, httpResponse) = try await URLSession.shared.response(request)
```

# Install

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/noppefoxwolf/Swinub", from: "0.0.x")
    ],
)
```

# Apps Using

<p float="left">
    <a href="https://apps.apple.com/app/id1668645019"><img src="https://github.com/noppefoxwolf/MediaViewer/blob/main/.github/dawn.png" height="65"></a>
</p>


# License

Swinub is available under the MIT license. See the LICENSE file for more info.
