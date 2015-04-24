class AccuracyTest
 	include Mongoid::Document
 	belongs_to :company
 	auto_increment :cid

 	DEFAULT_VALUES = {positive: 0, negative: 0, neutral: 0}
 	CATEGORIES = ["positive", "negative", "neutral"]

	field :positive, type: Hash, default: DEFAULT_VALUES
	field :negative, type: Hash, default: DEFAULT_VALUES
	field :neutral, type: Hash, default: DEFAULT_VALUES

	def insert_document(true_category, document)
		inc("#{true_category}.#{document.sentiment_name}" => 1)
		document.set(status: :tested)
	end


	# number of docs in class i classified correctly
	def recall category
		send(category).values.sum > 0 ? send(category)[category].fdiv(send(category).values.sum) : 0
	end

	#fraction of docs assigned class i that are actually about class i
	def precision category
		positive[category] + negative[category] + neutral[category] > 0 ? send(category)[category].fdiv(positive[category] + negative[category] + neutral[category]) : 0
	end

	def number_of_documents
		CATEGORIES.map { |category| send(category).values.sum }.sum
	end

	def number_of_right_classifications
		CATEGORIES.map { |category| send(category)[category] }.sum
	end

	#fraction of all docs classified correctly
	def accuracy
		number_of_documents > 0 ? number_of_right_classifications.fdiv(number_of_documents) : 0
	end

	def color
		case accuracy * 100
		when 0..30
			"#c0392b"
		when 31..70
			"#f1c40f" 
		when 71.100
			"#2ecc71"
		end	
	end


end
