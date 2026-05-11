import Foundation
import SwiftData

enum CastleSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            SubscriptionModel.self,
            PaymentRecordModel.self,
            NotificationSettingsModel.self,
            UserProfileModel.self
        ]
    }
}

enum CastleSchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CastleSchemaV1.self]
    }

    static var stages: [MigrationStage] { [] }
}
