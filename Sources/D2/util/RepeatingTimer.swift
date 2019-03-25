import Dispatch

fileprivate var globalTimerIndex: Int = 0

class RepeatingTimer {
	let intervalSeconds: Int
	private var timer: DispatchSourceTimer? = nil
	private var context: TimerContext
	var isRunning: Bool { return timer != nil }
	
	init(intervalSeconds: Int = 1) {
		self.intervalSeconds = intervalSeconds
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
		timer!.schedule(deadline: .now(), repeating: .seconds(intervalSeconds), leeway: .milliseconds(100))
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
