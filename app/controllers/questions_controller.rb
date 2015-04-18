class QuestionsController < ApplicationController
  before_action :authenticate_admin, except: :index
  before_action :fetch_question, only: [:edit,:update]

 	def index
 		@questions = Question.all
 	end

  def edit
    
  end

  def update
  	@question.update(question_params)
  	respond_to do |format|
   		format.html {redirect_to faq_path}
   	end 	
  end

  def new
  	@question = Question.new
  end

  def create
  	@question = Question.new(question_params)
    @question.save
		respond_to do |format|
    	format.html {redirect_to faq_path}
    end 		
  end
 
 	private
  
	def fetch_question
  	@question = Question.find(params[:id])
	end

	def question_params
		params.require(:question).permit(:text, :answer)
	end 

end
