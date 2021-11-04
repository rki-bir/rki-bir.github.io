#!/usr/bin/ruby

# example run: ./js2md.rb config-martin.yml example.json

# author: hoelzer.martin@gmail.com

# read in the js file from the py scraper script
# write out md for mkdocs 

require 'json'
require 'yaml'

md = File.open("publications.md",'w')
#######################
## Init publications md page
#article_counter = publications_hash['articles'].size
md << "# Publications\n\n"

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
config = config.merge(YAML.load_file('config-team.yml'))


#########################
## Get per article google scholar stats, and collect by year in hash
peer_reviewed = {}
preprint = {}
peer_reviewed_years = []
preprint_years = []

Dir.glob("config*.json").each do |json|

    # read in json file with google scholar information obtained via scrap.py
    file = File.read(json)
    publications_hash = JSON.parse(file)

    publications_hash['articles'].each do |article|

        year = article["year"]
        next if year.to_i < 2020 
        
        peer_reviewed[year] = [] unless peer_reviewed[year]
        preprint[year] = [] unless preprint[year]

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
    
        is_preprint = false
        config['preprints'].each do |preprint_tag|
            is_preprint = true if article["publication"] && article["publication"].include?(preprint_tag)
        end

        if is_preprint
            preprint_years.push(year.to_i) unless preprint_years.include?(year.to_i)
            preprint[year].push(article_md)
        else
            peer_reviewed_years.push(year.to_i) unless peer_reviewed_years.include?(year.to_i)
            peer_reviewed[year].push(article_md)
        end
    end
end

preprint_years.sort!.reverse!
peer_reviewed_years.sort!.reverse!

md << "## Preprints\n\n"
preprint_years.each do |y|
    year = y.to_s
    md << "### #{year}\n\n"
    md << preprint[year].join("\n\n")
    md << "\n\n"
end
md << "\n\n---\n\n## Peer-reviewed\n\n"
peer_reviewed_years.each do |y|
    year = y.to_s
    md << "### #{year}\n\n"
    md << peer_reviewed[year].join("\n\n")
    md << "\n\n"
end

md.close


