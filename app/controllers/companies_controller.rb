class CompaniesController < ApplicationController
  before_action :authenticate_user!
  
  
  def index
    @companies = Company.all
  end
    
end
