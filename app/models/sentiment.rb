class Sentiment
  include Mongoid::Document
  field :category, type: String
  
  has_many :words
  has_many :documents
  
  validates_inclusion_of :category, :in => ["positive", "negative", "neutral"]
  
  def self.positive
    find_by(category: "positive")
  end
  
  def self.negative
    find_by(category: "negative")
  end
  
  def self.neutral
    find_by(category: "neutral")
  end
  
  def compute_prior
    Document.count > 0 ? documents.count.fdiv(Document.count) : 0
  end
  
end
