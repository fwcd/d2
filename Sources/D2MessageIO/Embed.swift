public struct Embed {
	public let title: String
	public let color: Int?
	public let footer: Footer?
	public let fields: [Field]?
	
	public init(title: String, color: Int? = nil, footer: Footer? = nil, fields: [Field] = []) {
		self.title = title
		self.color = color
		self.footer = footer
		self.fields = fields
	}
	
	public struct Footer {
		public let text: String
		
		public init(text: String) {
			self.text = text
		}
	}
	
	public struct Field {
		public let name: String
		public let value: String
		
		public init(name: String, value: String) {
			self.name = name
			self.value = value
		}
	}
}
