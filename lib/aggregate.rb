module Twisent
    
  class Aggregate
    
    attr_reader :company, :period, :granularity
    attr_accessor :data_set
    
    def initialize(company, period = nil, granularity = nil)
      @company = company
      @granularity = granularity || :day
      @period = period || {start: Time.now - 1.send(@granularity), finish: Time.now}
    end
    
    def documents
      company.documents.between(created_at: period[:start]..period[:finish])
    end
    
    def quotes
      company.quotes.between(created_at: period[:start].to_date..period[:finish].to_date)
    end
    
    def growth start_value, end_value
      start_value != 0 ? end_value.fdiv(start_value) - 1 : 1
    end
    
    def price_change_between start_moment, end_monent
      if [:minute, :hour].include? granularity
        start_price = quotes.find_by(created_at: start_moment.to_date).get_price granularity, start_moment
        end_price = quotes.find_by(created_at: end_monent.to_date).get_price granularity, end_monent
      else
        start_price = quotes.find_by(created_at: start_moment.to_date).open
        end_price = quotes.find_by(created_at: start_moment.to_date).close
      end
      growth start_price, end_price
    end
    
    def retrieve_data
      data = {}
      point = period[:start]
      while point <= period[:finish]
        next_point = point + 1.send(granularity)
        data[point] = {}
        data[point][:quotes] = price_change_between point, next_point
        data[point][:sentiments] = documents.between(created_at: point..next_point).positive.count - documents.between(created_at: point..next_point).negative.count
        point = next_point
      end
      @data_set = data
    end
      
      
  end
end