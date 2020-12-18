import HealthKit

class SubscribeRequest {
    let types: [String]
    let sampleTypes: [(type: HKSampleType, unit: HKUnit)]
    let ignoreManualData: Bool

    private init(types: [String], sampleTypes: [(type: HKSampleType, unit: HKUnit)], ignoreManualData: Bool) {
        self.types = types
        self.sampleTypes = sampleTypes
        self.ignoreManualData = ignoreManualData
    }

    static func fromCall(call: FlutterMethodCall) throws -> SubscribeRequest {
        guard let arguments = call.arguments as? [String: Any],
              let types = arguments["types"] as? [String]
        else {
            throw "invalid call arguments \(call.arguments)"
        }

        let sampleTypes = try types.map { type -> (type: HKSampleType, unit: HKUnit) in
            try (
                type: HKSampleType.fromDartType(type: type),
                unit: HKUnit.fromDartType(type: type)
            )
        }
        let ignoreManualData = arguments["ignoreManualData"] as! Bool

        return SubscribeRequest(types: types, sampleTypes: sampleTypes, ignoreManualData: ignoreManualData)
    }
}