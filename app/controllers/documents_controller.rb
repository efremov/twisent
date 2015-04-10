class DocumentsController < ApplicationController
  before_action :fetch_document, only: [:update] 
  
  def index
    @documents = Document.training_set.where(sentiment_id: nil)
    
    respond_to do |format|
      format.html
    end  
  end
  
  
  def update
    @document.update(document_params)
    respond_to do |format|
      format.html {redirect_to documents_path}
      format.js
    end 
  end
  
  
  def fetch_document
    @document = Document.find(params[:id])
  end
  
  def document_params
    params.require(:document).permit(:sentiment_id)
  end
  
end