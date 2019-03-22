import Dispatch

fileprivate var globalTimerIndex: Int = 0

class RepeatingTimer {
	let intervalSeconds: Int
	private var timer: DispatchSourceTimer? = nil
	
	init(intervalSeconds: Int = 1) {
		self.intervalSeconds = intervalSeconds
	}
	
	func schedule(nTimes n: Int, action: @escaping () -> Void) {
		// (Re)start timer
		let queue = DispatchQueue(label: "RepeatingTimer #\(globalTimerIndex)")
		var count = 0
		
		globalTimerIndex += 1
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: queue)
		timer!.schedule(deadline: .now(), repeating: .seconds(intervalSeconds), leeway: .milliseconds(100))
		timer!.setEventHandler { [unowned self] in
			if count >= n {
				self.timer?.cancel()
				self.timer = nil
			} else {
				action()
				count += 1
			}
		}
		
		timer!.resume()
	}
}
