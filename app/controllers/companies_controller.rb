class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_company, only: [:show, :api]
  
  def show
    @aggregated_data = @company.quiry 
    respond_to do |format|
      format.html
      format.js
    end 	
  end

  def api
    @data = (params[:from] && params[:to]) ? @company.api_quiry(params[:metrics], params[:granularity], {start: params[:from], finish: params[:to]}) : @company.api_quiry(params[:metrics], params[:granularity])
   
    respond_to do |format|
      format.html { render text: @data, status: 200}
      format.json { render text: @data, status: 200}
      format.xml { render xml: @data, status: 200}
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
