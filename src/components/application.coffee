_.def('Luca.Application').extends('Luca.containers.Viewport').with

  # automatically starts the @router
  # if it exists, once the components
  # for the application have been created
  autoStartHistory: true

  # we will create a collection manager singleton
  # by default unless otherwise specified
  useCollectionManager: true

  # Luca plugin apps are apps which mount onto existing
  # luca apps, and will not have the behavior of a main
  # app which acts as a singleton
  plugin: false

  # by default, the application will use a controller
  # component, which is a card view container which shows
  # one view at a time.  this is useful for having an application
  # with several 'sections' so to speak
  useController: true

  #### Nested Components

  # applications have one component, the controller
  # any components defined on the application class directly
  # will get wrapped by the main controller unless you
  # set useController = false
  components:[
    ctype: 'template'
    name: 'welcome'
    template: 'sample/welcome'
    templateContainer: "Luca.templates"
  ]

  initialize: (@options={})->
    unless @plugin is true
      Luca.getApplication = ()-> @

    Luca.containers.Viewport::initialize.apply @, arguments

    if @useController is true
      definedComponents = @components || []

    @components = [
      ctype: 'controller'
      name: "main_controller"
      components: definedComponents
    ]

    if @useCollectionManager is true
      @collectionManager ||= Luca.CollectionManager.get?() || new Luca.CollectionManager()

    @state = new Backbone.Model( @defaultState )

    @bind "ready", ()=> @render()

  activeView: ()->
    if active = @activeSubSection()
      @view( active )
    else
      @view( @activeSection() )

  activeSubSection: ()->
    @get("active_sub_section")

  activeSection: ()->
    @get("active_section")

  afterComponents: ()->
    Luca.containers.Viewport::afterComponents?.apply @, arguments

    # any time the main controller card switches we should track
    # the active card on the global state chart
    @getMainController()?.bind "after:card:switch", (previous,current)=>
      @state.set(active_section:current.name)

    # any time the card switches on one of the sub controllers
    # then we should track the active sub section on the global state chart
    @getMainController()?.each (component)=>
      if component.ctype.match(/controller$/)
        component.bind "after:card:switch", (previous,current)=>
          @state.set(active_sub_section:current.name)

  beforeRender: ()->
    Luca.containers.Viewport::beforeRender?.apply @, arguments
    Backbone.history.start() if @router? and @autoStartHistory is true

  # boot should trigger the ready event, which will call the initial call
  # to render() your application, which will have a cascading effect on every
  # subcomponent in the view, recursively rendering everything which is set
  # to automatically render (i.e. any non-deferrable components ).
  #
  # you should use boot to fire up any dependent collections, manager, any
  # sort of data processing, whatever your application requires to run outside
  # of the views
  boot: ()->
    @trigger "ready"

  # delegate to the collection manager's get or create function.
  # use App.collection() to create or access existing collections
  collection: ()->
    @collectionManager.getOrCreate.apply(@collectionManager, arguments)

  get: (attribute)->
    @state.get(attribute)

  getMainController: ()->
    return @components[0] if @useController is true
    Luca.cache('main_controller')

  set: (attributes)->
    @state.set(attributes)

  view: (name)->
    Luca.cache(name)

  #### Navigation Hooks
  #
  # delegate to the main controller so that we can switch the active section
  navigate_to: (component_name, callback)->
    @getMainController().navigate_to(component_name, callback)


