# BezelNotification

A utility class for displaying Xcode-like notifications, aka bezel notifications.
It currently only supports displaying a given text that will be centered on screen, will remain on screen for the specified amount of time, then fade out.

It is based on Core Animation and NSVisualEffectView, all written in Swift 5. It requires macOS 10.14 or later. UI is written only to be able to distribute this as a Swift package.

![Bezel notification demo](demo.gif)

### Integration (SPM)

Just add this repo in your dependencies.

### Usage

```swift
let bezel = BezelNotification(text: "This is a sample message.")
bezel.runModal()
// or
bezel.show()
```
