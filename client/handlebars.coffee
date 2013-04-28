Handlebars.registerHelper "isResults", (showError) ->
  if Session.get 'is_result'
    true
  else
    false

Handlebars.registerHelper "isLanding", (showError) ->
  if Session.get 'is_result'
    false
  else
    true