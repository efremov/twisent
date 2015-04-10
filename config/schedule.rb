every 5.minutes do 
  runner "Company.load_data('training')", :environment => 'development'
end
