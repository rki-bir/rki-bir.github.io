#!/usr/bin/ruby

# example run: ./js2md.rb config-martin.yml example.json

# author: hoelzer.martin@gmail.com

# read in the js file from the py scraper script
# write out md for mkdocs 

require 'json'
require 'yaml'

team_member = ARGV[0]
config_file = ARGV[1]
scholar_json_file = ARGV[2]
md = File.open("#{team_member}.publications.md",'w')

# read in config parameters, e.g. from config-martin.yml
config = {
    "scholar_author_id" => nil,
    "email" => nil,
    "pdfs" => {},
    "highlight" => [],
    "altmetricDOIs" => [],
    "minCitations" => nil,
    "preprints" => [],
    "italicize" => []
  }
config = config.merge(YAML.load_file(config_file))

# read in json file with google scholar information obtained via scrap.py
file = File.read(scholar_json_file)
publications_hash = JSON.parse(file)

#########################
## Get overall google scholar stats
overall = publications_hash['cited_by']
overall_cites = overall['table'][0]['citations']['all']
h_index = overall['table'][1]['h_index']['all']

##### maybe useful later ...
#puts overall['graph']
#{"year"=>2016, "citations"=>6}
#{"year"=>2017, "citations"=>28}
#{"year"=>2018, "citations"=>39}
#{"year"=>2019, "citations"=>68}
#{"year"=>2020, "citations"=>168}
#{"year"=>2021, "citations"=>330}

#######################
## Init publications md page
article_counter = publications_hash['articles'].size
md << "## Publications <a href=\"https://scholar.google.de/citations?user=#{config['scholar_author_id']}\"><font size=\"3\">n=#{article_counter}, cites #{overall_cites}, h-index #{h_index}</font></a>\n\n"

#########################
## Get per article google scholar stats, and collect by year in hash
peer_reviewed = {}
preprint = {}

peer_reviewed_years = []
preprint_years = []
publications_hash['articles'].each do |article|
    title = article['title']
    config['italicize'].each do |italicize|
        if italicize.end_with?(' ')
            title.gsub!(italicize, "_#{italicize.strip}_ ") unless title.include?("_#{italicize}")
        else
            title.gsub!(italicize, "_#{italicize}_")
        end
    end
    article_md = "[#{title}](#{article['link']}) </br>\n"

    authors = article['authors']
    config['highlight'].each do |highlight|
        authors.sub!(highlight, "__#{highlight}__")
    end
    authors.sub!('...','_et al._')
    article_md += authors + " </br>\n"

    # apparently "publication" can be empty!
    article_md += article["publication"] + ' ' if article["publication"]

    cited_by = article["cited_by"]["value"]
    if cited_by && cited_by > config['minCitations'].to_i
        article_md += "[:octicons-person-16: Cited #{cited_by}x](#{article["cited_by"]["link"]})"
    end
    
    year = article["year"]
    peer_reviewed[year] = [] unless peer_reviewed[year]
    preprint[year] = [] unless preprint[year]

    is_preprint = false
    config['preprints'].each do |preprint_tag|
        is_preprint = true if article["publication"] && article["publication"].include?(preprint_tag)
    end

    if is_preprint
        preprint_years.push(year) unless preprint_years.include?(year)
        preprint[year].push(article_md)
    else
        peer_reviewed_years.push(year) unless peer_reviewed_years.include?(year)
        peer_reviewed[year].push(article_md)
    end
end

md << "### Preprints\n\n"
preprint_years.each do |year|
    md << "#### #{year}\n\n"
    md << preprint[year].join("\n\n")
    md << "\n\n"
end
md << "\n\n---\n\n### Peer-reviewed\n\n"
peer_reviewed_years.each do |year|
    md << "#### #{year}\n\n"
    md << peer_reviewed[year].join("\n\n")
    md << "\n\n"
end

md.close


# TODO: is it also possible to scrap the DOI/PMID from here?


##########################
## Cruft

#<html>
#     <ul class="doi-badges">
#        <li class="__dimensions_badge_embed__" data-doi="10.1111/1462-2920.15186" data-hide-zero-citations="true" data-legend="hover-right" data-style="small_rectangle" ></li>
#      </ul>
#        <script async src="https://badge.dimensions.ai/badge.js" charset="utf-8"></script>
#</html>
