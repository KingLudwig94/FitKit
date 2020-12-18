import Flutter
import HealthKit
import UIKit

public class SwiftFitKitPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?

    public func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }

    private let TAG = "FitKit"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fit_kit", binaryMessenger: registrar.messenger())
        let instance = SwiftFitKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(name: "fit_kit_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    private var healthStore: HKHealthStore?

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: TAG, message: "Not supported", details: nil))
            return
        }

        if healthStore == nil {
            healthStore = HKHealthStore()
        }

        do {
            if call.method == "hasPermissions" {
                let request = try PermissionsRequest.fromCall(call: call)
                hasPermissions(request: request, result: result)
            } else if call.method == "requestPermissions" {
                let request = try PermissionsRequest.fromCall(call: call)
                requestPermissions(request: request, result: result)
            } else if call.method == "revokePermissions" {
                revokePermissions(result: result)
            } else if call.method == "read" {
                let request = try ReadRequest.fromCall(call: call)
                read(request: request, result: result)
            } else if call.method == "subscribe" {
                let request = try SubscribeRequest.fromCall(call: call)
                subscribe(request: request, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: TAG, message: "Error \(error)", details: nil))
        }
    }

    /**
     * On iOS you can only know if user has responded to request access screen.
     * Not possible to tell if he has allowed access to read.
     *
     *   # getRequestStatusForAuthorization #
     *   If "status == unnecessary" means if requestAuthorization will be called request access screen will not be shown.
     *   So user has already responded to request access screen and kinda has permissions.
     *
     *   # authorizationStatus #
     *   If "status == notDetermined" user has not responded to request access screen.
     *   Once he responds no matter of the result status will be sharingDenied.
     */
    private func hasPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            healthStore!.getRequestStatusForAuthorization(toShare: [], read: Set(request.sampleTypes)) { status, error in
                guard error == nil else {
                    result(FlutterError(code: self.TAG, message: "hasPermissions", details: error))
                    return
                }

                guard status == HKAuthorizationRequestStatus.unnecessary else {
                    result(false)
                    return
                }

                result(true)
            }
        } else {
            let authorized = request.sampleTypes.map {
                healthStore!.authorizationStatus(for: $0)
            }
            .allSatisfy {
                $0 != HKAuthorizationStatus.notDetermined
            }
            result(authorized)
        }
    }

    private func requestPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: request.sampleTypes) { success, _ in
            guard success else {
                result(false)
                return
            }

            result(true)
        }
    }

    /**
     * Not supported by HealthKit.
     */
    private func revokePermissions(result: @escaping FlutterResult) {
        result(nil)
    }

    private func read(request: ReadRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: [request.sampleType]) { success, error in
            guard success else {
                result(error)
                return
            }

            self.readSample(request: request, result: result)
        }
    }

    private func subscribe(request: SubscribeRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: request.sampleTypes.map { (sampleType) -> HKSampleType in
            sampleType.type
        }) { success, _ in
            guard success else {
                result(false)
                return
            }

            self.subscribeToChanges(request: request, result: result)
        }
    }

    private func requestAuthorization(sampleTypes: [HKSampleType], completion: @escaping (Bool, FlutterError?) -> Void) {
        healthStore!.requestAuthorization(toShare: nil, read: Set(sampleTypes)) { success, error in
            guard success else {
                completion(false, FlutterError(code: self.TAG, message: "Error \(error?.localizedDescription ?? "empty")", details: nil))
                return
            }

            completion(true, nil)
        }
    }

    private func subscribeToChanges(request: SubscribeRequest, result: @escaping FlutterResult) {
        var predicates = [NSPredicate]()
        if request.ignoreManualData {
            predicates.append(NSPredicate(format: "metadata.%K != YES", HKMetadataKeyWasUserEntered))
        }
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)

        for sampleType in request.sampleTypes {
            let alreadySubscribe = UserDefaults.standard.bool(forKey: "fit_kit_subscribe_\(sampleType.type)")

            if !alreadySubscribe {
                let query = HKObserverQuery(sampleType: sampleType.type, predicate: compoundPredicate) {
                    _, completionHandler, error in

                    if error != nil {
                        result(FlutterError(code: self.TAG, message: "*** An error occured while setting up the observer. \(error?.localizedDescription) ***", details: error))
                        abort()
                    }

                    debugPrint("observer query update handler called for type \(sampleType.type), error: \(error)")

                    if #available(iOS 9.0, *) {
                        self.readNewSamples(sampleType: sampleType.type, unit: sampleType.unit, result: result)
                    } else {
                        self.readNewSamplesDeprecated(sampleType: sampleType.type, unit: sampleType.unit, result: result)
                    }

                    completionHandler()
                }

                healthStore!.enableBackgroundDelivery(for: sampleType.type, frequency: .immediate, withCompletion: { (succeeded: Bool, error: Error?) in

                    if succeeded {
                        debugPrint("Enabled background delivery for \(sampleType.type)")
                    } else {
                        debugPrint("Failed to enable background delivery for \(sampleType.type). Error = \(error)")
                    }
                })

                healthStore!.execute(query)

                UserDefaults.standard.set(true, forKey: "fit_kit_subscribe_\(sampleType.type)")
            }
        }

        result(true)
    }

    @available(iOS 9.0, *)
    private func readNewSamples(sampleType: HKSampleType, unit: HKUnit, result _: @escaping FlutterResult) {
        var anchor = HKQueryAnchor(fromValue: 0)

        if UserDefaults.standard.object(forKey: "Anchor") != nil {
            let data = UserDefaults.standard.object(forKey: "Anchor") as! Data
            anchor = NSKeyedUnarchiver.unarchiveObject(with: data) as! HKQueryAnchor
        }

        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) { _, samplesOrNil, _, newAnchor, errorOrNil in
            guard let samples = samplesOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }

            anchor = newAnchor!
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")

            print(samples)
            self._eventSink!(samples.map { sample -> NSDictionary in
                [
                    "value": self.readValue(sample: sample, unit: unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                    "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true,
                    "type": HKSampleType.toDartType(type: sample.sampleType),
                ]
            })

            print("Anchor: \(anchor)")
        }
        healthStore!.execute(query)
    }

    private func readNewSamplesDeprecated(sampleType: HKSampleType, unit: HKUnit, result _: @escaping FlutterResult) {
        var anchor = 0

        if UserDefaults.standard.object(forKey: "Anchor") != nil {
            anchor = UserDefaults.standard.integer(forKey: "Anchor")
        }

        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: 0, limit: HKObjectQueryNoLimit) { _, samplesOrNil, newAnchor, errorOrNil in
            guard let samples = samplesOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }

            anchor = newAnchor
            UserDefaults.standard.set(anchor, forKey: "Anchor")

            print(samples)
            self._eventSink!(samples.map { sample -> NSDictionary in
                [
                    "value": self.readValue(sample: sample, unit: unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                    "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true,
                    "type": HKSampleType.toDartType(type: sample.sampleType),
                ]
            })

            print("Anchor: \(anchor)")
        }
        healthStore!.execute(query)
    }

    private func readSample(request: ReadRequest, result: @escaping FlutterResult) {
        // if UIApplication.shared.isProtectedDataAvailable {
        if UIScreen.main.brightness != 0.0 {
            print("readSample: \(request.type)")

            let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom, end: request.dateTo, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: request.limit == nil)
            let query = HKSampleQuery(sampleType: request.sampleType, predicate: predicate, limit: request.limit ?? HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
                _, samplesOrNil, error in

                guard var samples = samplesOrNil else {
                    print("Error in fitkit: \(error)")
                    result(FlutterError(code: self.TAG, message: "Results are null", details: error))
                    return
                }

                if request.limit != nil {
                    // if limit is used sort back to ascending
                    samples = samples.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
                }

                print(samples)
                result(samples.map { sample -> NSDictionary in
                    [
                        "value": self.readValue(sample: sample, unit: request.unit),
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source": self.readSource(sample: sample),
                        "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true,
                        "type": HKSampleType.toDartType(type: sample.sampleType),
                        "unit": request.unit.unitString,
                    ]
                })
            }
            healthStore!.execute(query)
        } else {
            result([String: Any]())
        }
    }

    private func readValue(sample: HKSample, unit: HKUnit) -> Any {
        if let sample = sample as? HKQuantitySample {
            return sample.quantity.doubleValue(for: unit)
        } else if let sample = sample as? HKCategorySample {
            return sample.value
        }

        return -1
    }

    private func readSource(sample: HKSample) -> String {
        if #available(iOS 9, *) {
            return sample.sourceRevision.source.name
        }

        return sample.source.name
    }
}
