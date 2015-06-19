module Twisent
    
  class Aggregate
    
    attr_reader :company, :period, :granularity
    attr_accessor :data_set
    
    def initialize(company, granularity = nil, period = nil)
      @company = company
      @granularity = (granularity || :day).to_sym
      @period = period || {start: last_working_minute - 1.send(next_granularity), finish: last_working_minute}
      retrieve_data
    end

    

    def last_working_minute(moment = Time.now)
      if moment.wday.between?(1, 5)
        if moment.hour.between?(10, 17)
          return moment
        elsif moment.hour < 10
          date = moment.to_date.previous_business_day
          return Time.new(date.year, date.month, date.day, 18, 0,0)
        else
          date = moment.to_date
          return Time.new(date.year, date.month, date.day, 18, 0,0)
        end
      else
        date = moment.to_date.previous_business_day
        return Time.new(date.year, date.month, date.day, 18, 0,0)
      end
    end
    
    def next_granularity
      {minute: :day, hour: :week, day: :month, week: :month, month: :year}[granularity]    
    end
    
    def clusters
      company.clusters.between(created_at: period[:start].to_date..period[:finish].to_date)
    end
    
    
    def growth start_value, end_value
      return 0 if start_value == end_value
      end_value && start_value && start_value != 0 ? end_value.fdiv(start_value) - 1 : 1
    end
    
    
    def retrieve_data
      data = {}
      case granularity
      when :minute
        prev_value = 0
        clusters.order("created_at asc").each do |cluster|
          cluster.minutly.sort_by{|k,v| k.to_i}.to_h.each do |identificator, values|
            moment = Time.new(cluster.created_at.year, cluster.created_at.month, cluster.created_at.day, identificator.to_i / 60, identificator.to_i % 60, 1)
            if moment.between? period[:start], period[:finish]
              data[moment] = {
                growth: growth(prev_value, values["price"]),
                positive: values["positive"],
                negative: values["negative"],
                neutral: values["neutral"],
                iok: cluster.iok(values["positive"] || 0, values["negative"] || 0, values["neutral"] || 0),
                price: values["price"]
              }
              prev_value = values["price"]
            end
          end
        end
      when :hour
        prev_value = 0
        clusters.order("created_at asc").each do |cluster|
          cluster.hourly.sort_by{|k,v| k.to_i}.to_h.each do |identificator, values|
            moment = Time.new(cluster.created_at.year, cluster.created_at.month, cluster.created_at.day, identificator.to_i, 1, 1)
            if moment.between? period[:start], period[:finish]
              data[moment] = {
                growth: growth(prev_value, values["price"]),
                positive: values["positive"],
                negative: values["negative"],
                neutral: values["neutral"],
                iok: cluster.iok(values["positive"], values["negative"], values["neutral"]),
                price: values["price"]
              }
              prev_value = values["price"]
            end
          end
        end
      when :day
        clusters.order("created_at asc").each do |cluster|
          data[cluster.created_at] = {price: cluster.open, growth: cluster.price_growth, iok: cluster.iok, positive: cluster.positive, negative: cluster.negative, neutral: cluster.neutral}
        end
      end
      
      return @data_set = data
    end
      
      
  end
end