class SessionsController < Devise::SessionsController
    before_filter :set_meta, :only => :new

    private
    
    def set_meta
       set_meta_tags :title => 'Войдите в ваш аккаунт', :description => 'Войдите в ваш Twisent аккаунт'
    end
end