
CowText = '''
@*! I say moo! You say party! @>
@! Moo!                       @> Party!
@! Moo!                       @> Party!
'''

ShowEdit = true


$(document).ready ->
  # Hook updateCows to the submit button
  $('#cowsay-submit').click(updateCows)

  parseUrl()
  display()


parseUrl = ->
  param = window.location.hash
  console.log("param=[#{param}]")
  return false unless param.match(/^#(view|edit)\..+/)

  ShowEdit = param.substr(1, 4) == 'edit'
  CowText = LZString.decompressFromBase64(param.substr(6))
  return true


makeUrlPart = (action, text) ->
  '#' + action + '.' + LZString.compressToBase64(text)


display = () ->
  r = new CowSay
  rtext = r.render(CowText)

  $('#ascii_art').get(0).textContent = rtext
  $('#cowsay-input-form').attr('hidden', !ShowEdit)
  $('#cowsay-text').val(CowText)

  $('#cow-dlg-link')        .attr('href', makeUrlPart('view', CowText))
  $('#cow-dlg-link-edit')   .attr('href', makeUrlPart('edit', CowText))



updateCows = () ->
  CowText = $("#cowsay-text").val()
  display()
