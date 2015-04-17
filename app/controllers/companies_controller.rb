class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_company, only: [:show]
  
  def show
    @aggregated_data = @company.quiry 
    
    respond_to do |format|
      format.html
      format.js
    end 	
  end
  
  def index
    @companies = Company.all
  end
  
  private 
  
  def fetch_company
    @company = Company.find(params[:id])
  end
    
end
