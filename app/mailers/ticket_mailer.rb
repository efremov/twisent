class TicketMailer < ActionMailer::Base
  default from: "support@twisent.ru"


  def to_founder(ticket)
    @ticket = ticket
    mail(to: "efremov@datmachine.ru", subject: "Ticket" + " (request # #{@ticket.id})")
  end


end
