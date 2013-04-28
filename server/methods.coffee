Meteor.startup ->
  Future = Npm.require("fibers/future")
  console.log Future
# code to run on server at startup
  Meteor.methods 
    fetchFromService: (searchTerm) ->
      console.log searchTerm
      url = "http://api.dp.la/v2/items?api_key=08ff0483fd4916b9dafd6f46dc7d2599&q=" + searchTerm
      console.log url
      result = Meteor.http.get(url)
      if result.statusCode is 200
        JSON.parse result.content
      else
        console.log "error fetching: ", result.statusCode
        errorJson = JSON.parse(result.content)
        throw new Meteor.Error(result.statusCode, errorJson.error)

    getfromMebe: (query) ->
      url = 'http://mebe.co/' + query
      console.log url, query
      fut = new Future()
      Meteor.http.get url, (err, result) ->
        fut.ret result
        console.log result, err, 'mebe'
      fut.wait()
      console.log fut.wait()

    getfromCSE: (query) ->
      apikey = 'AIzaSyAoWqOndvtaDa1wPV6yBbPzBLSjkuub-hY' #tcnamenamename03@gmail.com BACKUP!!
      cx = '003613587362386192085:2ytzhiouvga' #tcnamenamename03@gmail.com BACKUP!!

      #apikey = 'AIzaSyBgAgezQXB3f8tG33jjHU-OnQw0VdaGmEo' #think.jackson@gmail.com
      #apikey = 'AIzaSyC799a059XAwFmRcbHo2JbFm7uT_El7fh8' #jollyburnz@gmail.com
      #apikey = 'AIzaSyCSjt_YVlS0qIAY_ppho573PAqU_LE-304' #tcnamenamename@gmail.com
      #apikey = 'AIzaSyCsn1xchEQmqoPydedp6_VD1GKGe5xl65g' #tcnamenamename02@gmail.com
      #cx = '005153554774963151093:iikbqfn8gwo'


      url = 'https://www.googleapis.com/customsearch/v1?key=' + apikey + '&cx=' + cx + '&q=' + query + '&searchType=image'
      console.log url, query
      fut = new Future()
      Meteor.http.get url, (err, result) ->
        fut.ret result
        #console.log result, err, 'mebe'
      fut.wait()

    getfromMyMemory: (query, language) ->
      url = 'http://api.mymemory.translated.net/get?q=' + query + '&langpair=en|' + language + "&de=info@translated.net"
      console.log url
      fut = new Future()
      Meteor.http.get url, (err, result) ->
        fut.ret result
      fut.wait()

    getfromYandex: (query, language) ->
      key = "trnsl.1.1.20130428T012421Z.0e330fbe0e33841c.7a3bf5965cd329e4c09ae6ea1ce082cc3f40d97b"
      url = 'https://translate.yandex.net/api/v1.5/tr.json/translate?key=' + key + '&lang=en-' + language + '&text=' + query
      console.log url
      fut = new Future()
      Meteor.http.get url, (err, result) ->
        fut.ret result
      fut.wait()