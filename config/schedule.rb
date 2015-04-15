every 1.minute do 
  runner "Company.load_data(:train)", :environment => 'development'
end
