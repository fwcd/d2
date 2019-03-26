import Dispatch

fileprivate var globalTimerIndex: Int = 0

class RepeatingTimer {
	let interval: DispatchTimeInterval
	private var timer: DispatchSourceTimer? = nil
	private var context: TimerContext
	var isRunning: Bool { return timer != nil }
	
	init(interval: DispatchTimeInterval = .seconds(1)) {
		self.interval = interval
		context = TimerContext()
		context.cancel = { [unowned self] in
			self.timer?.cancel()
			self.timer = nil
		}
	}
	
	func schedule(nTimes n: Int, action: @escaping (Int, TimerContext) -> Void) {
		// (Re)start timer
		let queue = DispatchQueue(label: "RepeatingTimer #\(globalTimerIndex)")
		var count = 0
		
		globalTimerIndex += 1
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: queue)
		timer!.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(100))
		timer!.setEventHandler { [unowned self] in
			if count >= n {
				self.context.cancel()
			} else {
				action(count, self.context)
				count += 1
			}
		}
		
		timer!.resume()
	}
}
