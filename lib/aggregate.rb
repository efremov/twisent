module Twisent
    
  class Aggregate
    
    attr_reader :company, :period, :granularity
    attr_accessor :data_set
    
    def initialize(company, granularity = nil, period = nil)
      @company = company
      @granularity = granularity || :day
      @period = period || {start: Time.now - 1.send(next_granularity), finish: Time.now}
      retrieve_data
    end
    
    def next_granularity
      {minute: :hour, hour: :day, day: :week, week: :month, month: :year}[granularity]    
    end
    
    def clusters
      company.clusters.between(created_at: period[:start].to_date..period[:finish].to_date)
    end
    
    
    def growth start_value, end_value
      start_value != 0 ? end_value.fdiv(start_value) - 1 : 1
    end
    
    
    def retrieve_data
      data = {}
      case granularity
      when :minute
        prev_value = 0
        clusters.each do |cluster|
          cluster.minutly.each do |identificator, values|
            moment = Time.new(cluster.created_at.year, cluster.created_at.month, cluster.created_at.day, identificator.to_i / 60, identificator.to_i % 60, 1)
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
      when :hour
        prev_value = 0
        clusters.each do |cluster|
          cluster.hourly.each do |identificator, values|
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
        clusters.each do |cluster|
          data[cluster.created_at] = {price: cluster.open, growth: cluster.growth, iok: cluster.iok, positive: cluster.positive, negative: cluster.negative, neutral: cluster.neutral}
        end
      end
      
      return @data_set = data
    end
      
      
  end
end