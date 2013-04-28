if Meteor.isClient
  doImageSearch2 = (query) ->
    #Meteor.call 'getfromGoogle', searchTerm, (err, res) ->
    #  Session.set 'data', res  if !err

    Meteor.call 'getfromCSE', query, (err, res) ->
      console.log res
      if !err
        i = 0
        while i < res.data.items.length
          result = {}
          result.query = query
          result.image = res.data.items[i].image.thumbnailLink
          search_results.push result
          console.log search_results
          Session.set 'images', search_results
          i++

  getTranslation = ->
    searchTerm = document.getElementById("searchInput").value
    console.log searchTerm
    #languages = ['es', 'it', 'cs', 'de', 'fr', 'ru']
    #languages = ['zh-CN', 'ja', 'ko-KR', 'ru', 'ru-RU', 'de-DE', 'it', 'fr-FR', 'es-US']
    languages = ['zh-CN', 'ja', 'ru']
    window.translated = [{lang:'original', text: searchTerm}]
    window.search_results = []
    doImageSearch2(searchTerm)
    languages.forEach (language) ->
      Meteor.call('getfromMyMemory', searchTerm, language, (err, res) ->
        #Session.set 'translation', res.data.matches[0].translation
        #console.log language
        #console.log res.data.matches[1].translation, language, 'from mymemory'
        #console.log res.data.responseData.translatedText
        lan = {}
        lan.lang = language
        lan.text = res.data.responseData.translatedText
        translated.push lan
        Session.set 'langs', translated
        doImageSearch2(lan.text)
      )
    
      ### BACKUP TRANSLATOR
      Meteor.call 'getfromYandex', searchTerm, language, (err, res) ->
        #console.log res
        #Session.set 'translation', res.data.matches[0].translation
        console.log res.data.text[0], 'from yandex'
        translated.push res.data.text[0]
        Session.set 'langs', translated
      ###

  doImageSearch = ->
    searchTerm = document.getElementById("searchInput").value
    console.log searchTerm
    Session.set 'name', searchTerm
    #Meteor.call 'getfromGoogle', searchTerm, (err, res) ->
    #  Session.set 'data', res  if !err

    Meteor.call 'getfromCSE', searchTerm, (err, res) ->
      console.log res
      if !err
        Session.set 'data', res
        #console.log "term: #{searchTerm}/results: #{res}"
        $results = $(results)
        $results.empty()
        i = 0

        while i < res.data.items.length
          image = res.data.items[i]
          #console.log image.link
          $results.append "<img src=#{image.image.thumbnailLink}>"
          i++

  Template.search.greeting = ->
    Session.get 'name'

  Template.search.translated = ->
    Session.get 'langs'

  Template.search.results = ->
    Session.get 'images'

  #Template.search.translation = ->
    #yq = encodeURIComponent("select json.json.json from google.translate where q='" + addslashes(message.text) + "' and source='" + message.userlang + "' and target='" + Session.get("userlang") + "' limit 1")
    #$.YQL yq, (data) ->
    #  post = data.query.results.json.json.json.json
    #  if post

  Template.search.events
    "click input.search": ->
   	  console.log 'hello'
      #doImageSearch()
      getTranslation()

    "keypress input.searchTerm": (evt) ->
      if evt.which is 13
        #doImageSearch()
        getTranslation()
if Meteor.isServer

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
        #apikey = 'AIzaSyBgAgezQXB3f8tG33jjHU-OnQw0VdaGmEo' #think.jackson@gmail.com
        apikey = 'AIzaSyC799a059XAwFmRcbHo2JbFm7uT_El7fh8' #jollyburnz@gmail.com
        cx = '009835190121848329682:btlz483ttee'
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