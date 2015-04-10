class Quote
  include Mongoid::Document
  belongs_to :company
  field :created_at, type: Date, default: Date.today
  field :data, type: Hash
  field :open, type: Float
  field :close, type: Float
  
  before_create :default_data
  
  def insert_quote(stock_info, time = Time.now)
    data[time.hour.to_s][time.min.to_s] = stock_info
    save
  end
    
  def default_data
    default_data = {}
    (0..23).each do |hour|
      default_data[hour.to_s] = {}
      (0..59).each do |minute|
        default_data[hour.to_s][minute.to_s] = {bid: 0, volume: 0, ask: 0, change_in_percent: 0}
      end
    end
    self.data = default_data
    self.open = YahooFinance.quotes([company.yahoo_ticker_symbol], [:ask, :bid, :volume, :change_in_percent, :open]).first.open.to_f
    
  end
  
  
  
end