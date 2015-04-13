class UsersController < ApplicationController
  before_filter :fetch_site
  before_filter :authenticate_user
  
  def show
    
  end
  
  
  private
    
    
  def fetch_site
    @user = User.find(params[:id])
  end
  
  def authenticate_user
    authenticate_user! && current_user == @user
    
  end
  
end
