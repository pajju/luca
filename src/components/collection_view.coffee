make = Luca.View::make

_.def("Luca.components.CollectionView").extends("Luca.components.Panel").with
  tagName: "div"

  className: "luca-ui-collection-view"

  bodyClassName: "collection-ui-panel"

  # A collection view can pass a model through to a template
  itemTemplate: undefined

  # A collection view can pass a model through a function which should return a string
  itemRenderer: undefined

  itemTagName: 'li'

  itemClassName: 'collection-item'

  initialize: (@options={})->
    _.extend(@, @options)

    _.bindAll @, "refresh"

    unless @collection?
      throw "Collection Views must specify a collection"

    unless @itemTemplate? || @itemRenderer?
      throw "Collection Views must specify an item template or item renderer function"

    Luca.components.Panel::initialize.apply(@, arguments)

    if Luca.isBackboneCollection(@collection)
      @collection.bind "reset", @refresh
      @collection.bind "add", @refresh
      @collection.bind "remove", @refresh

  attributesForItem: (item)->
    _.extend {}, class: @itemClassName, "data-index": item.index

  # expects an item object, which contains the
  contentForItem: (item={})->
    if @itemTemplate? and templateFn = Luca.template(@itemTemplate)
      content = templateFn.call(@, item)

    if @itemRenderer? and _.isFunction( @itemRenderer )
      content = @itemRenderer.call(@, item)

    content || ""

  makeItem: (model, index)->
    item = if @prepareItem? then @prepareItem.call(@, model, index) else (model:model, index: index)

    make(@itemTagName, @attributesForItem(item), @contentForItem(item))

  getModels: ()->
    @collection.models

  refresh: ()->
    panel = @

    @$bodyEl().empty()

    _( @getModels() ).each (model, index)->
      panel.$append( panel.makeItem(model, index) )

  registerEvent: (domEvent, selector, handler)->
    if !handler? and _.isFunction(selector)
      handler = selector
      selector = undefined

    eventTrigger = _([domEvent,"#{ @itemTagName }.#{ @itemClassName }", selector]).compact().join(" ")
    Luca.View::registerEvent(eventTrigger,handler)

  render: ()->
    @refresh()
    @$attach() if @$el.parent().length > 0 and @container?