//
// Created by Martin Anderson on 2019-03-10.
//

import HealthKit

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension HKSampleType {
    public static func fromDartType(type: String) throws -> HKSampleType {
        guard let sampleType: HKSampleType = {
            switch type {
            case "heart_rate":
                return HKSampleType.quantityType(forIdentifier: .heartRate)
            case "step_count":
                return HKSampleType.quantityType(forIdentifier: .stepCount)
            case "height":
                return HKSampleType.quantityType(forIdentifier: .height)
            case "weight":
                return HKSampleType.quantityType(forIdentifier: .bodyMass)
            case "distance":
                return HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
            case "energy":
                return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
            case "water":
                if #available(iOS 9, *) {
                    return HKSampleType.quantityType(forIdentifier: .dietaryWater)
                } else {
                    return nil
                }
            case "sleep":
                return HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
            case "blood_glucose":
                return HKSampleType.quantityType(forIdentifier: .bloodGlucose)
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported"
        }
        return sampleType
    }
}

extension HKUnit {
    public static func fromDartType(type: String) throws -> HKUnit {
        guard let unit: HKUnit = {
            switch type {
            case "heart_rate":
                return HKUnit(from: "count/min")
            case "step_count":
                return HKUnit.count()
            case "height":
                return HKUnit.meter()
            case "weight":
                return HKUnit.gramUnit(with: .kilo)
            case "distance":
                return HKUnit.meter()
            case "energy":
                return HKUnit.kilocalorie()
            case "water":
                return HKUnit.liter()
            case "sleep":
                return HKUnit.minute() // this is ignored
            case "blood_glucose":
                return HKUnit(from: "mg/dl")
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported"
        }
        return unit
    }
}

extension HKSampleType {
    public static func toDartType(type: HKSampleType) -> String {
        let sampleType: String 
            switch type.identifier {
            case "HKQuantityTypeIdentifierHeartRate":
                return "heart_rate"
            case "HKQuantityTypeIdentifierStepCount":
                return "step_count"
            case "HKQuantityTypeIdentifierHeight":
                return"height"
            case "HKQuantityTypeIdentifierBodyMass":
                return "weight"
            case "HKQuantityTypeIdentifierDistanceWalkingRunning":
                return "distance"
            case "HKQuantityTypeIdentifierActiveEnergyBurned":
                return"energy"
            case "HKQuantityTypeIdentifierDietaryWater":
                return "water"
            case "HKCategoryTypeIdentifierSleepAnalysis":
                return "sleep"
            case "HKQuantityTypeIdentifierBloodGlucose":
                return"blood_glucose"
            default:
                return ""
            
        }
        return sampleType
    }
}