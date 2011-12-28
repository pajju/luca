#### Luca Base View
Luca.View = Backbone.View.extend
  base: 'Luca.View'

# The Luca.View class adds some very commonly used patterns
# and functionality to the stock Backbone.View class. Features
# such as auto event binding, the facilitation of deferred rendering
# against a Backbone.Model or Backbone.Collection reset event, Caching
# views into a global Component Registry, and more.

Luca.View.original_extend = Backbone.View.extend

# By overriding Backbone.View.extend we are able to intercept
# some method definitions and add special behavior around them
# mostly related to render()
Luca.View.extend = (definition)->

  #### Rendering 
  #
  # Our base view class wraps the defined render() method
  # of the views which inherit from it, and does things like
  # trigger the before and after render events automatically.
  #
  # In addition, if the view has a deferrable property on it
  # then it will make sure that the render method doesn't get called
  # until.

  _original = definition.render

  _default = ()->
    console.log $(@container), $(@el), $(@el).html(), $(@container).html() if @debugMode is "verbose"

    if !$(@container).length > 0
      console.log "We have no container at #{ @container }" if @debugMode is "verbose"

    return unless $(@container) and $(@el) 
      if $(@el).html() isnt "" and $(@container).html() is ""
        console.log "Appending", @cid, $(@container), $(@el) if @debugMode is "verbose"
        $(@container).append( $(@el) )

  _base = _original || _default

  definition.render = ()->
    if @deferrable
      @deferrable.bind @deferrable_event, ()=>
        @trigger "before:render", @
        console.log "Deferrable Render", @cid if @debugMode is "verbose"
        _base.apply(@, arguments)
        @trigger "after:render", @

      @deferrable.fetch()
    else
      @trigger "before:render", @
      do ()=>
        console.log "Normal Render", @cid if @debugMode is "verbose"
        _base.apply(@, arguments)
      @trigger "after:render", @

  Luca.View.original_extend.apply @, [definition]

_.extend Luca.View.prototype,
  trigger: (@event)->
    console.log "Triggering", @event, @cid if @debugMode is "verbose"
    Backbone.View.prototype.trigger.apply @, arguments

  hooks:[
    "after:initialize",
    "before:render",
    "after:render"
  ]
  
  deferrable_event: "reset"

  initialize: (@options={})->
    @cid = _.uniqueId(@name) if @name?

    _.extend @, @options

    #### View Caching
    #
    # Luca.View(s) which get created get stored in a global cache by their
    # component id.  This allows us to re-use views when it makes sense
    Luca.cache( @cid, @ )

    @setupHooks( @options.hooks ) if @options.hooks
    @setupHooks Luca.View.prototype.hooks

    @trigger "after:initialize", @

  #### Hooks or Auto Event Binding
  # 
  # views which inherit from Luca.View can define hooks
  # or events which can be emitted from them.  Automatically,
  # any functions on the view which are named according to the
  # convention will automatically get run.  
  #
  # by default, all Luca.View classes come with the following:
  #
  # before:render     : beforeRender()
  # after:render      : afterRender()
  # after:initialize  : afterInitialize()
  setupHooks: (set)->
    set ||= @hooks
    
    _(set).each (event)=>
      parts = event.split(':')
      prefix = parts.shift()
      
      parts = _( parts ).map (p)-> _.capitalize(p)

      fn = prefix + parts.join('')
      
      @bind event, ()=>
        @[fn].apply @, arguments if @[fn]