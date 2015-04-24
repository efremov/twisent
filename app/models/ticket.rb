class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :send_email

  field :email, type: String
  field :name, type: String
  field :message, type: String

  validates_presence_of :email
  validates_presence_of :message  


  def send_email
  	TicketMailer.delay.to_founder(self)
  end

end
