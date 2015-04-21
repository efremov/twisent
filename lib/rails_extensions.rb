require "unicode";

class String
   def downcase
     Unicode::downcase(self)
   end
   def downcase!
     self.replace downcase
   end
   def upcase
     Unicode::upcase(self)
   end
   def upcase!
     self.replace upcase
   end
   def capitalize
     Unicode::capitalize(self)
   end
   def capitalize!
     self.replace capitalize
   end
end

class Date
  def previous_business_day
    skip_weekends(self, -1)
  end

  def skip_weekends(date, inc)
    date += inc
    while (date.wday % 7 == 0) or (date.wday % 7 == 6) do
      date += inc
    end   
    date
  end

end
