on_that_masonry = (results)->
  console.log 'masonry'
  $container = $("#results")
  gutter = 0
  min_width = 80
  $container.imagesLoaded ->
    console.log 'LOADED'
    $container.masonry
      itemSelector: ".box"
      gutterWidth: gutter
      isAnimated: true
      columnWidth: (containerWidth) ->
        num_of_boxes = (containerWidth / min_width | 0)
        box_width = (((containerWidth - (num_of_boxes - 1) * gutter) / num_of_boxes) | 0)
        box_width = containerWidth  if containerWidth < min_width
        $(".box").width box_width
        box_width

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
        on_that_masonry()
        el = "<div class='box'><img src=#{result.image} alt=#{result.query}></div>"
        $('#results').append(el).masonry('reload')
        i++

getTranslation = (searchTerm) ->
  #searchTerm = document.getElementById("searchInput").value 
  console.log searchTerm
  #languages = ['es', 'it', 'cs', 'de', 'fr', 'ru']
  #languages = ['zh-CN', 'ja', 'ko-KR', 'ru', 'ru-RU', 'de-DE', 'it', 'fr-FR', 'es-US']
  languages = ['zh-CN']
  window.translated = [{lang:'original', text: searchTerm}]
  window.search_results = []
  #doImageSearch2(searchTerm)
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
        console.log i


Template.search.greeting = ->
  Session.get 'name'

Template.search.translated = ->
  Session.get 'langs'

Template.results.results = ->
  Session.get 'images'


Template.main.events
  "click a#search-button": ->
 	  console.log 'hello'
    $('body').css({"background-color":"white"})
    getTranslation(document.getElementById("searchInput").value)
    Session.set 'is_result', true


  "keypress input.main-search": (evt) ->
    if evt.which is 13
      $('body').css({"background-color":"white"})
      getTranslation(document.getElementById("searchInput").value)
      Session.set 'is_result', true

Template.results_header.events
  "click button.search-mit": ->
    $('body').css({"background-color":"white"})
    getTranslation($('.search-query-results').val())
    Session.set 'is_result', true


  "keypress input.search-query-results": (evt) ->
    if evt.which is 13
      $('body').css({"background-color":"white"})
      getTranslation(('.search-query-results').val())
      Session.set 'is_result', true
