Sandbox.Main = Luca.containers.ColumnView.extend
  el: '#viewport'
  name : 'viewport'
  layout: '100'
  components:[
    ctype: 'grid_view'
    store:
      base_url: "/sandbox/api"
    columns:[
      header: "Name"
      data: "name"
    ,
      header: "Location"
      data: "location"
    ]
  ]

Luca.registry.addNamespace('Sandbox.views')
