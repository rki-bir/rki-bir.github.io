from serpapi import GoogleSearch
import json

# pip install google-search-results

params = {
  "engine": "google_scholar_author",
  "num": "100",
  "author_id": "DMZ7Hc8AAAAJ",
  "hl": "en",
  "sort": "pubdate",
  "api_key": "60cf7008c3e1ce29b035df39469eeb88b498abb2343719af1a055891d25c9a7d"
}

search = GoogleSearch(params)
results = search.get_dict()

with open('result.json', 'w') as fp:
    json.dump(results, fp)