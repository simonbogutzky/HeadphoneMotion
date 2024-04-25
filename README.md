# HeadphoneMotion for iOS

HeadphoneMotion manages motion-related data from headphones using Apple's CoreMotion API. It handles the entire lifecycle of motion data collection from headphones, including initiating updates, processing received motion data, and handling connection and disconnection events. 

## Installing HeadphoneMotion
HeadphoneMotion supports [Swift Package Manager](https://www.swift.org/package-manager/)

### Github Repo

You can pull the [HeadphoneMotionManager Github Repo](https://github.com/simonbogutzky/HeadphoneMotion) and include the `HeadphoneMotionManager.swift` in your project.

### Swift Package Manager

To install HeadphoneMotion using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the HeadphoneMotionManager repo with the current version:

1. In Xcode, select “File” → “Add Packages...”
1. Enter https://github.com/simonbogutzky/HeadphoneMotion.git

or you can add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/simonbogutzky/HeadphoneMotion.git", from: "1.0.0")
```

## Integration

### Start and Stop

```swift
func startHeadphoneMotionUpdates() {
    do {
        headphoneMotionManager.delegate = self
        try headphoneMotionManager.startDeviceMotionUpdates()
    } catch {
        let headphoneMotionManagerError = error as? HeadphoneMotionManagerError

        switch headphoneMotionManagerError {
        case .authorizationStatusRestricted:
            break
        case .authorizationStatusDenied:
            break
        case .authorizationStatusUnknown:
            break
        case .deviceMotionIsNotAvailable:
            break
        case .deviceMotionIsActive:
            break
        case .none:
            break
        }
    }
}

func stopHeadphoneMotionUpdates() {
    headphoneMotionManager.stopDeviceMotionUpdates()
}
```

### Delegate Implementation

```swift
extension TestView: HeadphoneMotionManagerDelegate {
    func headphoneMotionManagerDidConnect() {}

    func headphoneMotionManagerDidDisconnect() {}

    func headphoneMotionManagerDidReceiveDeviceMotion(_ motion: CMDeviceMotion) {
        print(motion.attitude.roll)
    }

    func headphoneMotionManagerDidFailWithError(_ error: any Error) {}
}
```

## Contributing

I always appreciate contributions from the community. 
