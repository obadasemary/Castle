import Foundation
import SwiftData
import Core
import Domain
import Data
import Presentation

@MainActor
final class AppDependencyContainer {
    let modelContainer: ModelContainer
    let coordinator: AppCoordinator
    let clock: any Clock
    let calendarProvider: any CalendarProvider
    let popularServicesCatalog: any PopularServicesCatalog

    let subscriptionRepository: any SubscriptionRepository
    let paymentRepository: any PaymentRepository
    let notificationSettingsRepository: any NotificationSettingsRepository
    let userProfileRepository: any UserProfileRepository
    let reminderScheduler: any SubscriptionReminderScheduling

    private init(
        modelContainer: ModelContainer,
        coordinator: AppCoordinator,
        clock: any Clock,
        calendarProvider: any CalendarProvider,
        popularServicesCatalog: any PopularServicesCatalog,
        subscriptionRepository: any SubscriptionRepository,
        paymentRepository: any PaymentRepository,
        notificationSettingsRepository: any NotificationSettingsRepository,
        userProfileRepository: any UserProfileRepository,
        reminderScheduler: any SubscriptionReminderScheduling
    ) {
        self.modelContainer = modelContainer
        self.coordinator = coordinator
        self.clock = clock
        self.calendarProvider = calendarProvider
        self.popularServicesCatalog = popularServicesCatalog
        self.subscriptionRepository = subscriptionRepository
        self.paymentRepository = paymentRepository
        self.notificationSettingsRepository = notificationSettingsRepository
        self.userProfileRepository = userProfileRepository
        self.reminderScheduler = reminderScheduler
    }

    static func live() -> AppDependencyContainer {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainerFactory.production()
        } catch {
            assertionFailure("Falling back to in-memory ModelContainer: \(error)")
            modelContainer = try! ModelContainerFactory.inMemory()
        }
        return AppDependencyContainer(
            modelContainer: modelContainer,
            coordinator: AppCoordinator(),
            clock: SystemClock(),
            calendarProvider: SystemCalendarProvider(),
            popularServicesCatalog: BundledPopularServicesCatalog(),
            subscriptionRepository: SwiftDataSubscriptionRepository(modelContainer: modelContainer),
            paymentRepository: SwiftDataPaymentRepository(modelContainer: modelContainer),
            notificationSettingsRepository: SwiftDataNotificationSettingsRepository(modelContainer: modelContainer),
            userProfileRepository: SwiftDataUserProfileRepository(modelContainer: modelContainer),
            reminderScheduler: UNUserNotificationScheduler()
        )
    }
}

extension AppDependencyContainer: SubscriptionsViewModelFactory {
    func makeSubscriptionsListViewModel() -> SubscriptionsListViewModel {
        SubscriptionsListViewModel(
            repository: subscriptionRepository,
            fetchActive: FetchActiveSubscriptionsUseCase(repository: subscriptionRepository),
            archiveUseCase: ArchiveSubscriptionUseCase(
                repository: subscriptionRepository,
                reminderScheduling: reminderScheduler
            ),
            deleteUseCase: DeleteSubscriptionUseCase(
                subscriptionRepository: subscriptionRepository,
                paymentRepository: paymentRepository,
                reminderScheduling: reminderScheduler
            ),
            router: coordinator
        )
    }

    func makeSubscriptionDetailViewModel(id: UUID) -> SubscriptionDetailViewModel {
        SubscriptionDetailViewModel(
            subscriptionID: id,
            fetchDetail: FetchSubscriptionDetailUseCase(
                subscriptionRepository: subscriptionRepository,
                paymentRepository: paymentRepository,
                clock: clock,
                calendarProvider: calendarProvider
            ),
            updateUseCase: UpdateSubscriptionUseCase(
                repository: subscriptionRepository,
                reminderScheduling: reminderScheduler
            ),
            archiveUseCase: ArchiveSubscriptionUseCase(
                repository: subscriptionRepository,
                reminderScheduling: reminderScheduler
            ),
            deleteUseCase: DeleteSubscriptionUseCase(
                subscriptionRepository: subscriptionRepository,
                paymentRepository: paymentRepository,
                reminderScheduling: reminderScheduler
            ),
            router: coordinator
        )
    }

    func makeAddSubscriptionViewModel() -> AddSubscriptionViewModel {
        AddSubscriptionViewModel(
            listPopular: ListPopularServicesUseCase(catalog: popularServicesCatalog),
            validate: ValidateSubscriptionInputUseCase(clock: clock),
            suggestNextDate: SuggestNextBillingDateUseCase(
                clock: clock,
                calendarProvider: calendarProvider
            ),
            addUseCase: AddSubscriptionUseCase(
                repository: subscriptionRepository,
                reminderScheduling: reminderScheduler
            ),
            router: coordinator
        )
    }
}

extension AppDependencyContainer: DashboardViewModelFactory {
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            userProfileRepository: userProfileRepository,
            calculateMonthlySpend: CalculateMonthlySpendUseCase(repository: subscriptionRepository),
            buildSpendingTrend: BuildSpendingTrendUseCase(
                paymentRepository: paymentRepository,
                clock: clock,
                calendarProvider: calendarProvider
            ),
            calculateBudgetProgress: CalculateBudgetProgressUseCase(
                subscriptionRepository: subscriptionRepository,
                userProfileRepository: userProfileRepository
            ),
            fetchUpcoming: FetchUpcomingPaymentsUseCase(
                repository: subscriptionRepository,
                clock: clock,
                calendarProvider: calendarProvider
            ),
            fetchRecentActivity: FetchRecentActivityUseCase(paymentRepository: paymentRepository),
            router: coordinator
        )
    }
}
