class TicketsController < ApplicationController
  before_action :authenticate_admin, only: :index


  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.save

	  respond_to do |format|
      format.html {redirect_to root_path}
      format.js
    end 		
  end
 
  def index
    @tickets = Ticket.all
  end

  def ticket_params
    params.require(:ticket).permit(:email, :name, :message)
  end 

end
