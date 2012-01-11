_.mixin( _.string )

window.Luca =
  VERSION: "0.2.9"
  core: {}
  containers: {}
  components: {}
  modules: {}
  fields: {}
  util: {}
  registry:
    classes: {}
    namespaces:["Luca.containers","Luca.components"]
  component_cache:
    cid_index: {}
    name_index: {}

# adds an additional namespace to look for luca ui
# components.  useful for when you define a bunch of
# components in your own application's namespace
Luca.registry.addNamespace = (identifier)->
  Luca.registry.namespaces.push( identifier )
  Luca.registry.namespaces = _( Luca.registry.namespaces ).uniq()

# stores or looks up a component in the component cache
# by its backbone @cid or by its component_name
Luca.cache = (needle, component)->
  Luca.component_cache.cid_index[ needle ] = component if component?

  component = Luca.component_cache.cid_index[ needle ]
  
  # optionally, cache it by tying its name to its cid for easier lookups
  if component?.component_name?
    Luca.component_cache.name_index[ component.component_name ] = component.cid
  else if component?.name?
    Luca.component_cache.name_index[ component.name ] = component.cid

  return component if component?

  # perform a lookup by name if the component_id didn't turn anything
  lookup_id = Luca.component_cache.name_index[ needle ]

  Luca.component_cache.cid_index[ lookup_id ]

# Takes an string like "deep.nested.value" and an object like window
# and returns the value of window.deep.nested.value
Luca.util.nestedValue = (accessor, source_object)->
  _( accessor.split(/\./) ).inject (obj,key)->
    obj = obj?[key]
  , source_object

# Lookup a component in the Luca component registry
# by it's ctype identifier.  If it doesn't exist,
# check any other registered namespace
Luca.registry.lookup = (ctype)->
  c = Luca.registry.classes[ctype]

  return c if c?

  className = _.camelize _.capitalize( ctype )

  parents = _( Luca.registry.namespaces ).map (namespace)-> Luca.util.nestedValue(namespace, window)
  
  _.first _.compact _( parents ).map (parent)-> parent[className]

# creates a new object from a hash with a ctype property
# matching something in the Luca registry
Luca.util.LazyObject = (config)->
  ctype = config.ctype
  
  component_class = Luca.registry.lookup( ctype )

  throw "Invalid Component Type: #{ ctype }.  Did you forget to register it?" unless component_class

  constructor = eval( component_class )

  new constructor(config)

# for lazy component creation
Luca.register = (component, constructor_class)->
  exists = Luca.registry.classes[component]

  if exists?
    throw "Can not register component with the signature #{ component }. Already exists"
  else
    Luca.registry.classes[component] = constructor_class

Luca.available_templates = (filter="")->
  available = _( Luca.templates ).keys()

  if filter.length > 0
    _( available ).select (tmpl)-> tmpl.match(filter)
  else
    available

Luca.util.isIE = ()->
  try
    Object.defineProperty({}, '', {})
    return false
  catch e
    return true

Luca.util.is_renderable = (component={})->
  if Luca.registry.lookup(component.ctype)
    return true
  if _.isFunction(component.render)
    return true



$ do -> 
  $('body').addClass('luca-ui-enabled')
