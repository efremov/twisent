class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :name, type: String
  field :message, type: String

  validates_presence_of :email
  validates_presence_of :message  
end
