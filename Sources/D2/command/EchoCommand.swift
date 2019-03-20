import Sword
import Foundation
import Dispatch

fileprivate let argPattern = try! Regex(from: "(?:(\\d+)\\s*)?([\\s\\S]*)")

class EchoCommand: Command {
	let description = "Repeats something n times"
	let intervalSeconds: Int
	private var timer: DispatchSourceTimer? = nil
	
	init(intervalSeconds: Int = 1) {
		self.intervalSeconds = intervalSeconds
	}
	
	func invoke(withMessage message: Message, args: String) {
		if let groups = argPattern.firstGroups(in: args) {
			// Extract parsed values
			let n = groups[safe: 1].flatMap { Int($0) } ?? 1
			guard let value = groups[safe: 2] else { return }
			
			// (Re)start timer
			let queue = DispatchQueue(label: "EchoCommand")
			var count = 0
			
			timer?.cancel()
			
			timer = DispatchSource.makeTimerSource(queue: queue)
			timer!.schedule(deadline: .now(), repeating: .seconds(intervalSeconds), leeway: .milliseconds(100))
			timer!.setEventHandler { [unowned self] in
				if count >= n {
					self.timer?.cancel()
					self.timer = nil
				} else {
					message.channel.send(value)
					count += 1
				}
			}
			
			timer!.resume()
		}
	}
}
