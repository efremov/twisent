class Question
  include Mongoid::Document
  field :text, type: String
  field :answer, type: String
end
