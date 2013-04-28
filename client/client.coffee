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