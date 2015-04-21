every 1.minute do 
	runner "Company.load_data(:train)", :environment => 'development'
end

every 1.day do
	runner "Company.build_model", :environment => 'development'
end