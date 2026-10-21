# Swinub

[![Swift Package Manager Test](https://github.com/noppefoxwolf/Swinub/actions/workflows/workflow.yml/badge.svg)](https://github.com/noppefoxwolf/Swinub/actions/workflows/workflow.yml)

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

# PKCE

`OAuthOutOfBandAuthenticationService` and both CLI authentication flows use PKCE
with S256 automatically. Mastodon supports PKCE from version 4.3.

For a custom authentication flow, create one `OAuthPKCE` per authorization attempt:

```swift
import SwinubAuthenticationServices

let pkce = OAuthPKCE()
let factory = WebAuthenticationSessionDataFactory(
    host: host,
    clientId: application.clientId,
    redirectUri: redirectURI,
    scopes: [.read],
    pkce: pkce
)
let authorizationURL = try factory.makeURL()
// Open authorizationURL and receive the authorization code.
let request = PostOAuthToken(
    host: host,
    clientId: application.clientId,
    clientSecret: application.clientSecret,
    redirectUri: redirectURI,
    code: code,
    scopes: [.read],
    codeVerifier: pkce.codeVerifier
)
```

Keep the same verifier until token exchange. Do not log or include it in the
browser URL. The low-level factory and token request preserve their existing
behavior when PKCE arguments are omitted.

# Apps Using

<p float="left">
    <a href="https://apps.apple.com/app/id1668645019"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/dev.noppe.snowfox.png" height="65"></a>
</p>


# License

Swinub is available under the MIT license. See the LICENSE file for more info.
