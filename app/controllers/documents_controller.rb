class DocumentsController < ApplicationController
  before_action :fetch_document, only: [:update] 
  before_action :fetch_company, only: [:index, :update]
  
  def index
    docs = @company ? @company.documents : Document.all
    @documents = docs.training_set.where(sentiment_id: nil).paginate(:page => params[:page], per_page: 100)
    
    respond_to do |format|
      format.html
    end  
  end
  
  
  def update
    @document.update(document_params)
    respond_to do |format|
      format.html {redirect_to company_documents_path(@company)}
      format.js
    end 
  end
  
  private
  
  def fetch_company
    @company = params[:company_id] ? Company.find(params[:company_id]) : nil
  end
  
  def fetch_document
    @document = Document.find(params[:id])
  end
  
  def document_params
    params.require(:document).permit(:sentiment_id)
  end
  
end
