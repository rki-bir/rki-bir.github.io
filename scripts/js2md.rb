# read on the js file from the py scraper
# write out md 

require 'json'

file = File.read('example.json')

data_hash = JSON.parse(file)

data_hash['articles'].each do |article|
    article['title']

    article['link']
    article['authors']
    article["publication"]
    article["cited_by"]["value"]
    article["cited_by"]["link"]
    article["year"]

end

puts data_hash['cited_by']

# "cited_by"=>{"table"=>[{"citations"=>{"all"=>642, "since_2016"=>641}}, {"h_index"=>{"all"=>14, "since_2016"=>14}}, {"i10_index"=>{"all"=>16, "since_2016"=>16}}], "graph"=>[{"year"=>2016, "citations"=>6}, {"year"=>2017, "citations"=>28}, {"year"=>2018, "citations"=>39}, {"year"=>2019, "citations"=>68}, {"year"=>2020, "citations"=>168}, {"year"=>2021, "citations"=>330}]}, "public_access"=>{"link"=>"https://scholar.google.com/citations?view_op=list_mandates&hl=en&user=DMZ7Hc8AAAAJ", "available"=>19, "not_available"=>0},