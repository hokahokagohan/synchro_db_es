import random

def random_words(track, params, **kwargs):
  if len(track.indices) == 1:
    default_index = track.indices[0].name
    if len(track.indices[0].types) == 1:
      default_type = track.indices[0].types[0].name
    else:
      default_type = None
  else:
    default_index = '_all'
    default_type = None
    
  index_name = params.get('index', default_index)
  type_name = params.get('type', default_type)
  
  return {
    "body": {
      "query":{
        "multi_match": {
          "query": '%s' % random.choice(params["words"]),
          "fields": ["title" , "text_morph", "text_ngram^0.1"]
        }
      }
    },
    "index": index_name,
    "type": type_name,
    "cache": params.get('cache', False)
  }

def register(registry):
  registry.register_param_source('my-custom-term-param-source', random_words)