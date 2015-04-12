class RegistrationsController < Devise::RegistrationsController
    before_filter :set_meta, :only => :new

    private
    
    
    def set_meta
      set_meta_tags :title => 'Регистрация', :description => 'Создайте ваш Twisent аккаунт'         
    end
end