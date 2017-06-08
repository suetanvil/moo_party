

class TextFill

  constructor: (width) ->
    @width = width

  width: @width

  tokenize: (text) =>
    tokens = []

    # Split on whitespace
    while true
      m = text.match(/^\s*(\S+)\s*([^]*)/)
      break unless m
      [_, tok, text] = m
      tokens.push tok

    return tokens

  # Merge into a block of width @width
  mergeToBlock: (tokens) =>
    result = []
    current = ''

    # Append an impossible value so that the last line can be
    # discarded.
    tokens = tokens.concat('')

    first = true
    while tokens.length
      tok = tokens.shift()

      # Split and hyphenate a token if it's longer than the maximum
      # width.  (This is really crude; the user should really be
      # handling this.)
      if tok.length > @width
        tokens.unshift( tok.substring(@width - 3) )
        tok = tok.substring(0, @width - 3) + '-'

      if current.length + 1 + tok.length > @width || tokens.length == 0
        current += ' '.repeat(@width - current.length)
        result.push current
        current = tok
      else
        current += ' ' unless first
        current += tok

      first = false

    return result


class CowPanelBuilder

  constructor: (textfill) ->
    @cow = '''
           \\   ^__^
            \\  (oo)\\_______
               (__)\\       )\\/\\
                   ||----w |
                   ||     ||
           '''.split("\n")
    @cowWidth = Math.max( (@cow.map( (l) -> l.length ))... )
    @cow = @cow.map (l) => l + ' '.repeat(@cowWidth - l.length)

    @textfill = textfill   #new TextFill(width)

    @leftBorderWidth = 2        # '| '
    @rightBorderWidth = 2       # ' |'
    @borderWidth = @leftBorderWidth + @rightBorderWidth

    @panelWidth = textfill.width + @borderWidth
    @speechOffset = 4   # max. distance from cow to speech-bubble line

  makePanel: (text, reverse) =>
    panel = @makeBubble(text, reverse)
    panel.push( @makeCow(reverse, panel.length == 0) ... )
    return panel

  makeSingleLineBubble: (text, reverse) =>
    text = text.trim()
    return [] if text == ''

    text = '< ' + text + ' >'

    # Do the math assuming an unreversed cow.  (Unreversed Cow is the
    # name of my next band.)
    width = text.length
    cowLeft = Math.ceil( (@panelWidth - @cowWidth) / 2 )

    leftPadSz = Math.max(0, cowLeft - Math.round( width / 2 ))
    rightPadSz = @panelWidth - (leftPadSz + width)

    leftPad  = ' '.repeat( leftPadSz )
    rightPad = ' '.repeat( rightPadSz )

    [rightPad, leftPad] = [leftPad, rightPad] if reverse

    bar = (c) => ' ' + c.repeat(text.length - 2) + ' '  # merge?
    return [
      bar('_'),
      text,
      bar('-')
    ].map( (l) => leftPad + l + rightPad )


  makeBubble: (text, reverse) =>
    return [] if text.length == 0

    lines = @textfill.mergeToBlock(text)
    return @makeSingleLineBubble(lines[0], reverse) if lines.length == 1

    width = @textfill.width

    first = '/ '  + lines.shift() + ' \\'
    last =  '\\ ' + lines.pop()   + ' /'
    lines = lines.map( (l) -> '| ' + l + ' |' )
    lines.unshift(first)
    lines.push(last)

    border = (ll) =>
      ' ' + ll.repeat(width + 2) + ' '.repeat(@textfill.width + 1 - width)
    lines.unshift(border('_'))
    lines.push(border('-'))

    return lines

  _replaceAt: (str, index, newStr) =>
    return str.substr(0, index) + newStr + str.substr(index + newStr.length)

  makeCow: (reverse, silent) =>
    cow = @cow.slice()  # make a working copy

    if silent
      cow[0] = @_replaceAt(cow[0], 0, ' ')
      cow[1] = @_replaceAt(cow[1], 1, ' ')

    if reverse
      cow = cow.map (line) ->
        parts = line.split('').reverse()
        parts = parts.map (c) ->
          switch c
            when '/'    then '\\'
            when '\\'   then '/'
            when '('    then ')'
            when ')'    then '('
            else c
        parts.join('')

    # Symmetric pads to center the cow within 'width'
    pad = @panelWidth - cow[0].length
    return cow if pad <= 0

    left = ' '.repeat(Math.ceil(pad/2))
    right = ' '.repeat(Math.floor(pad/2))
    cow = cow.map (l) -> left + l + right

    return cow



class CowSay

  constructor: () ->
    @textfill = new TextFill(40)
    @builder = new CowPanelBuilder(@textfill)

  render: (text) =>
    text = text.replace(/[^\x00-\x7f]/g, '?')
    commands = @parse(text)
    frames = @assemble(commands)
    return frames.map( (f) => f.join("\n") ).join("\n\n\n")

  ##
  # Metatags:
  #
  #     @       - Separator
  #     @@      - '@' (escape)
  #     @[><*]  - Cow directive:
  #         >   - next panel goes to the right
  #         !   - Mirror the cow in the next panel
  #         *   - Discard previous panel
  #

  parse: (text) =>
    toks = @textfill.tokenize(text)
    toks.push( '@' )        # Ensure that the last text is processed

    commands = []
    curr = []
    flags = ['firstcmd']    # value is unused but good for debugging
    for tok in toks

      if ! tok.match(/^@[^a-zA-Z0-9]*$/)
        curr.push(tok)
        continue

      if tok.match(/^@@/)
        curr.push(tok.substr(1))
        continue

      # If we get here, we've found a separator
      commands.push( [flags, curr] )
      curr = []
      flags = ['cmd']       # value is unused but good for debugging

      for c in tok[1..].split('')
        switch c
          when '>' then flags.push('right')
          when '!' then flags.push('reverse')
          when '*'
            commands.pop() if commands.length > 0

    return commands


  assemble: (commands) =>
    panels = []

    for [cmd, tokens] in commands
      continue if cmd.includes('noshow')

      panel = @builder.makePanel(tokens, cmd.includes('reverse'))

      if cmd.includes('right') && panels.length > 0
        left = panels.pop()
        panel = @joinPanels(left, panel)

      panels.push(panel)

    return panels


  joinPanels: (left, right) =>
    newheight = Math.max(left.length, right.length)
    toPad = if left.length > right.length then right else left
    width = toPad[0].length

    pad = ' '.repeat(width)
    [0 ... (newheight - toPad.length)].forEach => toPad.unshift( pad )

    result = []
    for n in [0 ... newheight ]
      result.push(left[n] + "     " + right[n] )

    return result
