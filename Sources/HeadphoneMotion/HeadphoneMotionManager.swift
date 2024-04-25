//
//  HeadphoneMotionManager.swift
//  HeadphoneMotion
//

import CoreMotion
import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    nonisolated(unsafe) static let headphoneMotionManager = Logger(subsystem: subsystem, category: "HeadphoneMotion")
}

extension CMDeviceMotion: @unchecked Sendable {}

public protocol HeadphoneMotionManagerDelegate: AnyObject {
    // MARK: - Methods

    @MainActor func headphoneMotionManagerDidConnect()
    @MainActor func headphoneMotionManagerDidDisconnect()
    @MainActor func headphoneMotionManagerDidReceiveDeviceMotion(_ deviceMotion: CMDeviceMotion)
    @MainActor func headphoneMotionManagerDidFailWithError(_ error: Error)
}

public enum HeadphoneMotionManagerError: Error {
    case authorizationStatusRestricted
    case authorizationStatusDenied
    case authorizationStatusUnknown
    case deviceMotionIsNotAvailable
    case deviceMotionIsActive
}

public final class HeadphoneMotionManager: NSObject, @unchecked Sendable {
    // MARK: - Properties

    private let headphoneMotionManager = CMHeadphoneMotionManager()
    private let queue = OperationQueue()
    private let logger = Logger.headphoneMotionManager
    public weak var delegate: HeadphoneMotionManagerDelegate?

    // MARK: - Initializers

    override public init() {}

    // MARK: - Methods

    public func startDeviceMotionUpdates() throws {
        switch CMHeadphoneMotionManager.authorizationStatus() {
        case .notDetermined:
            logger.warning("Headphone motion manager authorization status is not determined.")
        case .restricted:
            logger.warning("Headphone motion manager authorization status is restricted.")
            throw HeadphoneMotionManagerError.authorizationStatusRestricted
        case .denied:
            logger.warning("Headphone motion manager authorization status is denied.")
            throw HeadphoneMotionManagerError.authorizationStatusDenied
        case .authorized:
            logger.log("Headphone motion manager authorization status is authorized.")
        @unknown default:
            logger.warning("Headphone motion manager authorization status is unknown.")
            throw HeadphoneMotionManagerError.authorizationStatusUnknown
        }

        if !headphoneMotionManager.isDeviceMotionAvailable {
            logger.log("Device motion is not available.")
            throw HeadphoneMotionManagerError.deviceMotionIsNotAvailable
        }

        guard !headphoneMotionManager.isDeviceMotionActive else {
            logger.log("Device motion is active.")
            throw HeadphoneMotionManagerError.deviceMotionIsActive
        }

        headphoneMotionManager.delegate = self

        logger.log("Start device motion updates.")

        headphoneMotionManager.startDeviceMotionUpdates(to: queue) { [unowned self] (deviceMotion: CMDeviceMotion?, error: Error?) in
            if let deviceMotion {
                Task { @MainActor in
                    delegate?.headphoneMotionManagerDidReceiveDeviceMotion(deviceMotion)
                }

            } else if let error {
                logger.error("\(error.localizedDescription)")
                Task { @MainActor in
                    delegate?.headphoneMotionManagerDidFailWithError(error)
                }
            }
        }
    }

    public func stopDeviceMotionUpdates() {
        headphoneMotionManager.stopDeviceMotionUpdates()
        logger.log("Device motion updates stopped.")
    }
}

extension HeadphoneMotionManager: CMHeadphoneMotionManagerDelegate {
    // MARK: - Methods

    public func headphoneMotionManagerDidConnect(_: CMHeadphoneMotionManager) {
        logger.log("Device motion connected.")
        Task { @MainActor in
            delegate?.headphoneMotionManagerDidConnect()
        }
    }

    public func headphoneMotionManagerDidDisconnect(_: CMHeadphoneMotionManager) {
        logger.log("Device motion disconnected.")
        Task { @MainActor in
            delegate?.headphoneMotionManagerDidDisconnect()
        }
    }
}
