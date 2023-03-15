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

// Defining a class that represents a kitchen appliance (e.g. stove, oven) with a timer
class KitchenAppliance {
    let id: String // A unique identifier for the appliance
    
    private(set) var isTimerRunning: Bool = false // A boolean flag indicating whether the timer is currently running
    private(set) var currentTimeInSeconds: Int = 0 // The current time on the timer in seconds
    private var timer: Timer? = nil // The Timer object that controls the timer
    
    // A DateComponentsFormatter object for formatting the current time on the timer into a human-readable string
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()
    
    // Initializing the object with the given id
    init(id: String) {
        self.id = id
    }
    
    // Starting the timer for the appliance
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: tick) // Creating a new Timer object that fires every second and calls the tick() method
        isTimerRunning = true
    }
    
    // The method called by the Timer object every second while the timer is running
    func tick(_ timer: Timer) {
        guard isTimerRunning else { return } // Checking if the timer is still running
        currentTimeInSeconds += 1 // Incrementing the current time on the timer by one second
    }
    
    // Stopping the timer for the appliance
    func stopTimer() {
        timer?.invalidate() // Invalidating the Timer object to stop the timer
        isTimerRunning = false
        currentTimeInSeconds = 0 // Resetting the current time on the timer
    }
    
    // Formatting the current time on the timer into a human-readable string (e.g. "05:37")
    func secondsToHoursMinutesSeconds() -> String {
        formatter.string(from: TimeInterval(currentTimeInSeconds))!
    }
}


// Extending the KitchenAppliance class to conform to the Equatable protocol
extension KitchenAppliance: Equatable {
    static func == (lhs: KitchenAppliance, rhs: KitchenAppliance) -> Bool {
        lhs.id == rhs.id
    }
}

