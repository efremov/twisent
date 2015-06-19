class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_company, only: [:show, :api, :edit, :update, :destroy]

  def new
    @company = Company.new
  end

  def create
    @company = Company.create(company_params)
    redirect_to @company
  end

  def edit
  end

  def update
    @company = Company.update(company_params)
    redirect_to @company   
  end

  def destroy
    @company = Company.destroy
    reditect_to companies_path
  end
  
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

  def company_params
    params.require(:company).permit(:name, :stock_ticker_symbol)
  end
  
  def fetch_company
    @company = Company.find(params[:id])
  end
    
end
