import Foundation

protocol TimersDelegate {
    func didAddNewTimer(id: String)
    func didStopTimer(id: String)
}

class KitchenTimer: ObservableObject {
    @Published var elements: [KitchenAppliance] = []
}

extension KitchenTimer: TimersDelegate {
    func didAddNewTimer(id: String) {
        let kitchenAppliance = KitchenAppliance(id: id)
        elements.append(kitchenAppliance)
        kitchenAppliance.startTimer()
    }
    
    func didStopTimer(id: String) {
        guard let kitchenApplianceIndex = elements.firstIndex(where: { $0.id == id}) else { return }
        elements[kitchenApplianceIndex].stopTimer()
        elements.remove(at: kitchenApplianceIndex)
    }
}

class KitchenAppliance {
    let id: String

    private(set) var isTimerRunning: Bool = false
    private(set) var currentTimeInSeconds: Int = 0
    private var timer: Timer? = nil
    
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()

    
    init(id: String) {
        self.id = id
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: tick)
        isTimerRunning = true
    }
    
    func tick(_ timer: Timer) {
        guard isTimerRunning else { return }
        currentTimeInSeconds += 1
    }
    
    func stopTimer() {
        timer?.invalidate()
        isTimerRunning = false
        currentTimeInSeconds = 0
    }
    
    func secondsToHoursMinutesSeconds() -> String {
        formatter.string(from: TimeInterval(currentTimeInSeconds))!
    }
}

extension KitchenAppliance: Equatable {
    static func == (lhs: KitchenAppliance, rhs: KitchenAppliance) -> Bool {
        lhs.id == rhs.id
    }
}

