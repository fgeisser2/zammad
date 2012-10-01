$ = jQuery.sub()

$.fn.item = (genericObject) ->
  elementID   = $(@).data('id')
  elementID or= $(@).parents('[data-id]').data('id')
  genericObject.find(elementID)

class App.ChannelEmail extends App.ControllerTabs
  constructor: ->
    super

    @tabs = [
      {
        name:       'Inbound',
        target:     'c-inbound',
        controller: App.ChannelEmailInbound,
      },
      {
        name:       'Outbound',
        target:     'c-outbound', 
        controller: App.ChannelEmailOutbound,
      },
      {
        name:       'Sigantures',
        target:     'c-signature',
        controller: App.ChannelEmailSignature,
      },
      {
        name:       'Adresses',
        target:     'c-address',
        controller: App.ChannelEmailAddress,
      },
      {
        name:   'Filter',
        target: 'c-filter',
      },
      {
        name:       'Settings',
        target:     'c-setting',
        controller: App.SettingsArea,
        params:     { area: 'Email::Base' },
      },
    ]

    @render()

class App.ChannelEmailAddress extends App.Controller
  events:
    'click [data-type=new]':  'new'
    'click [data-type=edit]': 'edit'

  constructor: ->
    super

    App.EmailAddress.bind 'refresh change', @render
    App.EmailAddress.fetch()

  render: =>
    data = App.EmailAddress.all()

    html = $('<div></div>')

    table = @table(
      model:    App.EmailAddress,
      objects:  data,
    )

    html.append( table )
    html.append( '<a data-type="new" class="btn">' + T('New') + '</a>' )
    @html html

  new: (e) =>
    e.preventDefault()
    new App.ChannelEmailAddressEdit()

  edit: (e) =>
    e.preventDefault()
    item = $(e.target).item( App.EmailAddress )
    new App.ChannelEmailAddressEdit( object: item )

class App.ChannelEmailAddressEdit extends App.ControllerModal
  constructor: ->
    super
    @render(@object)

  render: (data = {}) ->
    if @object
      @html App.view('generic/admin/edit')(
        head: 'Email-Address'
      )
      @form = new App.ControllerForm(
        el:        @el.find('#object_edit'),
        model:     App.EmailAddress,
        params:    @object,
        autofocus: true,
      )
    else
      @html App.view('generic/admin/new')(
        head: 'Email-Address'
      )
      @form = new App.ControllerForm(
        el:        @el.find('#object_new'),
        model:     App.EmailAddress,
        autofocus: true,
      )
    @modalShow()

  submit: (e) =>
    e.preventDefault()

    # get params
    params = @formParam(e.target)

    object = @object || new App.EmailAddress
    object.load(params)

    # validate form
    errors = @form.validate( params )

    # show errors in form
    if errors
      @log 'error new', errors
      @formValidate( form: e.target, errors: errors )
      return false

    # save object
    object.save(
      success: =>
        @modalHide()
      error: =>
        @log 'errors'
        @modalHide()
    )

class App.ChannelEmailSignature extends App.Controller
  events:
    'click [data-type=new]':  'new'
    'click [data-type=edit]': 'edit'

  constructor: ->
    super

    App.Signature.bind 'refresh change', @render
    App.Signature.fetch()

  render: =>
    data = App.Signature.all()

    html = $('<div></div>')

    table = @table(
      model:    App.Signature,
      objects:  data,
    )

    html.append( table )
    html.append( '<a data-type="new" class="btn">' + T('New') + '</a>' )
    @html html

  new: (e) =>
    e.preventDefault()
    new App.ChannelEmailSignatureEdit()

  edit: (e) =>
    e.preventDefault()
    item = $(e.target).item( App.Signature )
    @log '123', item, $(e.target)
    new App.ChannelEmailSignatureEdit( object: item )

class App.ChannelEmailSignatureEdit extends App.ControllerModal
  constructor: ->
    super
    @render(@object)

  render: (data = {}) ->
    if @object
      @html App.view('generic/admin/edit')(
        head: 'Signature'
      )
      @form = new App.ControllerForm(
        el:        @el.find('#object_edit'),
        model:     App.Signature,
        params:    @object,
        autofocus: true,
      )
    else
      @html App.view('generic/admin/new')(
        head: 'Signature'
      )
      @form = new App.ControllerForm(
        el:        @el.find('#object_new'),
        model:     App.Signature,
        autofocus: true,
      )
    @modalShow()

  submit: (e) =>
    e.preventDefault()

    # get params
    params = @formParam(e.target)

    object = @object || new App.Signature
    object.load(params)

    # validate form
    errors = @form.validate( params )

    # show errors in form
    if errors
      @log 'error new', errors
      @formValidate( form: e.target, errors: errors )
      return false

    # save object
    object.save(
      success: =>
        @modalHide()
      error: =>
        @log 'errors'
        @modalHide()
    )

class App.ChannelEmailInbound extends App.Controller
  events:
    'click [data-type=new]':  'new'
    'click [data-type=edit]': 'edit'

  constructor: ->
    super

    App.Channel.bind 'refresh change', @render
    App.Channel.fetch()

  render: =>
    channels = App.Channel.all()
    
    html = $('<div></div>')
    data = []
    for channel in channels
      if channel.area is 'Email::Inbound'
        channel.host = channel.options['host']
        channel.user = channel.options['user']
        data.push channel

    table = @table(
      header:   ['Host', 'User', 'Adapter', 'Active'],
      overview: ['host', 'user', 'adapter', 'active'],
      model:    App.Channel,
      objects:  data,
    )

    html.append( table )
    html.append( '<a data-type="new" class="btn">' + T('New') + '</a>' )
    @html html

  new: (e) =>
    e.preventDefault()
    new App.ChannelEmailInboundEdit()

  edit: (e) =>
    e.preventDefault()
    item = $(e.target).item( App.Channel )
    new App.ChannelEmailInboundEdit( object: item )


class App.ChannelEmailInboundEdit extends App.ControllerModal
  constructor: ->
    super
    @render(@object)

  render: (data = {}) ->

    configure_attributes = [
      { name: 'adapter',  display: 'Type',     tag: 'select',   multiple: false, null: false, options: { IMAP: 'IMAP', POP3: 'POP3' } , class: 'span4', default: data['adapter'] },
      { name: 'host',     display: 'Host',     tag: 'input',    type: 'text', limit: 120, null: false, class: 'span4', autocapitalize: false, default: (data['options']&&data['options']['host']) },
      { name: 'user',     display: 'User',     tag: 'input',    type: 'text', limit: 120, null: false, class: 'span4', autocapitalize: false, default: (data['options']&&data['options']['user']) },
      { name: 'password', display: 'Password', tag: 'input',    type: 'password', limit: 120, null: false, class: 'span4', autocapitalize: false, default: (data['options']&&data['options']['password']) },
      { name: 'ssl',      display: 'SSL',      tag: 'select',   multiple: false, null: false, options: { true: 'yes', false: 'no' } , class: 'span4', default: (data['options']&&data['options']['ssl']) },
      { name: 'group_id', display: 'Group',    tag: 'select',   multiple: false, null: false, filter: @edit_form, nulloption: false, relation: 'Group', class: 'span4', default: data['group_id']  },
      { name: 'active',   display: 'Active',   tag: 'select',   multiple: false, null: false, options: { true: 'yes', false: 'no' } , class: 'span4', default: data['active'] },
    ]
    if @object
      @html App.view('generic/admin/edit')(
        head: 'Channel'
      )
      @form = new App.ControllerForm(
        el: @el.find('#object_edit'),
        model: { configure_attributes: configure_attributes, className: '' },
        autofocus: true,
      )
    else
      @html App.view('generic/admin/new')(
        head: 'Channel'
      )
      @form = new App.ControllerForm(
        el: @el.find('#object_new'),
        model: { configure_attributes: configure_attributes, className: '' },
        autofocus: true,
      )
    @modalShow()

  submit: (e) =>
    e.preventDefault()

    # get params
    params = @formParam(e.target)

    object = @object || new App.Channel
    object.load(
      area:    'Email::Inbound',
      adapter:  params['adapter'],
      group_id: params['group_id'],
      options: {
        host:     params['host'],
        user:     params['user'],
        password: params['password'],
        ssl:      params['ssl'],
      },
    )

    # validate form
    errors = @form.validate( params )

    # show errors in form
    if errors
      @log 'error new', errors
      @formValidate( form: e.target, errors: errors )
      return false

    # save object
    object.save(
      success: =>
        @modalHide()
      error: =>
        @log 'errors'
        @modalHide()
    )

class App.ChannelEmailOutbound extends App.Controller
  events:
    'change #_adapter':     'toggle'
    'submit #mail_adapter': 'update'

  constructor: ->
    super

    App.Channel.bind 'refresh change', @render
    App.Channel.fetch()

  render: =>

    @html App.view('channel/email_outbound')()

    # get current Email::Outbound channel
    channels     = App.Channel.all()
    adapters     = {}
    adapter_used = undefined
    channel_used = undefined
    for channel in channels
      if channel.area is 'Email::Outbound'

        adapters[channel.adapter] = channel.adapter
        if @adapter_used
          if @adapter_used is channel.adapter
            adapter_used = channel.adapter
            channel_used = channel
        else if channel.active is true
            adapter_used = channel.adapter
            channel_used = channel

    configure_attributes = [
      { name: 'adapter', display: 'Send Mails via', tag: 'select', multiple: false, null: false, options: adapters , class: 'span4', default: adapter_used },
    ]
    new App.ControllerForm(
      el: @el.find('#form-email-adapter'),
      model: { configure_attributes: configure_attributes, className: '' },
      autofocus: true,
    )

#    if adapter_used is 'Sendmail'
#      # some form

    if adapter_used is 'SMTP'
      configure_attributes = [
        { name: 'host',     display: 'Host',     tag: 'input',    type: 'text', limit: 120, null: false, class: 'span4', autocapitalize: false, default: (channel_used['options']&&channel_used['options']['host']) },
        { name: 'user',     display: 'User',     tag: 'input',    type: 'text', limit: 120, null: true, class: 'span4', autocapitalize: false, default: (channel_used['options']&&channel_used['options']['user']) },
        { name: 'password', display: 'Password', tag: 'input',    type: 'password', limit: 120, null: true, class: 'span4', autocapitalize: false, default: (channel_used['options']&&channel_used['options']['password']) },
        { name: 'ssl',      display: 'SSL',      tag: 'select',   multiple: false, null: false, options: { true: 'yes', false: 'no' } , class: 'span4', default: (channel_used['options']&&channel_used['options']['ssl']) },
      ]
      @form = new App.ControllerForm(
        el: @el.find('#form-email-adapter-settings'),
        model: { configure_attributes: configure_attributes, className: '' },
        autofocus: true,
      )

  toggle: (e) =>

    # get params
    params = @formParam(e.target)

    # set selected adapter
    @adapter_used = params['adapter']

    # render page with new selected adapter
    @render()

  update: (e) =>
    e.preventDefault()
    params   = @formParam(e.target)

#    errors = @form.validate( params )

    # update Email::Outbound adapter
    channels = App.Channel.all()
    for channel in channels
      if channel.area is 'Email::Outbound' && channel.adapter is params['adapter']
        channel.updateAttributes(
          options: {
            host:     params['host'],
            user:     params['user'],
            password: params['password'],
            ssl:      params['ssl'],
          },
          active: true,
        )

    # set all other Email::Outbound adapters to inactive
    channels = App.Channel.all()
    for channel in channels
      if channel.area is 'Email::Outbound' && channel.adapter isnt params['adapter']
        channel.updateAttributes( active: false )

    # rerender page
    @render()
