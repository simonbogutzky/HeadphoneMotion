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

### Plist 

Add Privacy - Motion Usage Description

### Service Example

```swift
final class HeadphoneMotionService: NSObject, ObservableObject {
    // MARK: - Properties

    private let headphoneMotionManager = HeadphoneMotionManager()
    @Published private(set) var state: State = .disconnected

    // MARK: - Methods

    func pause() {
        headphoneMotionManager.stopDeviceMotionUpdates()
        headphoneMotionManager.delegate = nil
    }

    func resume() {
        headphoneMotionManager.delegate = self
        do {
            try headphoneMotionManager.startDeviceMotionUpdates()
        } catch {
            let headphoneMotionManagerError = error as? HeadphoneMotionManagerError

            switch headphoneMotionManagerError {
            case .authorizationStatusRestricted:
                state = .unauthorized
            case .authorizationStatusDenied:
                state = .unauthorized
            case .authorizationStatusUnknown:
                state = .unauthorized
            case .deviceMotionIsNotAvailable:
                state = .failure(error)
            case .deviceMotionIsActive:
                state = .fetchingFirstDeviceMotion
            case .none:
                state = .failure(NSError(domain: "HeadphoneMotionService", code: -1000))
            }
        }
    }
}

extension HeadphoneMotionService {
    enum State {
        case unauthorized
        case connected
        case disconnected
        case fetchingFirstDeviceMotion
        case latestDeviceMotion(CMDeviceMotion)
        case failure(Error)
    }
}

extension HeadphoneMotionService: HeadphoneMotionManagerDelegate {
    // MARK: - Methods

    func headphoneMotionManagerDidConnect() {
        state = .connected
    }

    func headphoneMotionManagerDidDisconnect() {
        state = .disconnected
    }

    func headphoneMotionManagerDidReceiveDeviceMotion(_ motion: CMDeviceMotion) {
        state = .latestDeviceMotion(motion)
    }

    func headphoneMotionManagerDidFailWithError(_ error: any Error) {
        state = .failure(error)
    }
}
```

## Contributing

I always appreciate contributions from the community. 
