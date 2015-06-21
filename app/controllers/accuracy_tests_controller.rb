class AccuracyTestsController < ApplicationController
	before_action :fetch_company
	before_action :fetch_test, only: [:update]

	def show
		@documents = @company.documents.testing_set.paginate(:page => params[:page], per_page: 100)
		respond_to do |format|
      		format.html
    	end  
	end

	def update
		
		if params[:document_id] && params[:true_category]
			@document = Document.find(params[:document_id])
			if @document
				@test ||= AccuracyTest.create(company_id: @company.id)
				@test.insert_document(params[:true_category], @document)
			end 
		end

		respond_to do |format|
      		format.html {redirect_to test_company_path(@company)}
      		format.js
    	end  
	end


	private

	def fetch_company
		@company = Company.find(params[:id])
	end

	def fetch_test
		@test = @company.accuracy_test
	end


end
