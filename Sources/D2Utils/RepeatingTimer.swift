import Dispatch

fileprivate var globalTimerIndex: Int = 0

public class RepeatingTimer {
	public let interval: DispatchTimeInterval
	private var timer: DispatchSourceTimer? = nil
	private var context: TimerContext
	public var isRunning: Bool { return timer != nil }
	
	public init(interval: DispatchTimeInterval = .seconds(1)) {
		self.interval = interval
		context = TimerContext()
		context.cancel = { [unowned self] in
			self.timer?.cancel()
			self.timer = nil
		}
	}
	
	public func schedule(nTimes n: Int = 1, beginImmediately: Bool = true, action: @escaping (Int, TimerContext) -> Void) {
		// (Re)start timer
		let queue = DispatchQueue(label: "RepeatingTimer #\(globalTimerIndex)")
		var count = 0
		
		globalTimerIndex += 1
		timer?.cancel()
		
		timer = DispatchSource.makeTimerSource(queue: queue)
		let deadline: DispatchTime = beginImmediately ? .now() : .now() + interval
		timer!.schedule(deadline: deadline, repeating: interval, leeway: .milliseconds(100))
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
