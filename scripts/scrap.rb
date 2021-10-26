#!/usr/bin/ruby

require 'google_search_results' 

params = {
  engine: "google_scholar_author",
  hl: "en",
  author_id: "DMZ7Hc8AAAAJ",
  num: "100",
  sort: "pubdate",
  api_key: "60cf7008c3e1ce29b035df39469eeb88b498abb2343719af1a055891d25c9a7d"
}

search = GoogleSearch.new(params)
hash_results = search.get_hash
