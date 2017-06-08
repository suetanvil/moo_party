

cowtest = () ->
  cs = new CowSay
  txt = cs.render("""
@*!
Everything's great in this good old world;
(This is the stuff they can always use.)
God's in his heaven, the hill's dew-pearled;
(This will provide for baby's shoes.)
Hunger and War do not mean a thing;
Everything's rosy where'er we roam;
Hark, how the little birds gaily sing!
(This is what fetches the bacon home.)
		-- Dorothy Parker

@>
Really?

@!
Sure.  It's a classic.

@>
Moooooo.

@
A serious, long-running classic!

@>
Mooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo.


@!

@>
?

@!
Mooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo.

@?%$
This is just a cow.  @cow on twitter.  moo@cow.com by email.  @@>! is
not a separator.

@
This is traditional Chinese text: 我說moo你說派對！


""")

  console.log(txt)


cowtest()