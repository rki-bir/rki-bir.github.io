from serpapi import GoogleSearch
import json, yaml, sys, os

# pip install google-search-results

a_yaml_file = open(sys.argv[1])
parsed_yaml_file = yaml.load(a_yaml_file, Loader=yaml.FullLoader)
scholar_id = parsed_yaml_file["scholar_author_id"]

params = {
  "engine": "google_scholar_author",
  "num": "100",
  "author_id": scholar_id,
  "hl": "en",
  "sort": "pubdate",
  "api_key": "60cf7008c3e1ce29b035df39469eeb88b498abb2343719af1a055891d25c9a7d" # this is martins API key, can be used 100x per month only!
}

search = GoogleSearch(params)
results = search.get_dict()

bn = os.path.splitext(os.path.basename(sys.argv[1]))[0]
with open(bn+".json", 'w') as fp:
    json.dump(results, fp)