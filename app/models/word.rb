class Word
  include Mongoid::Document
  field :name, type: String
  field :frequency, type: Integer, default: 0
  
  belongs_to :sentiment
  validates_presence_of :name
  
  
  
  
end
