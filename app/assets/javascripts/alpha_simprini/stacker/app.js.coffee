class Stacker.App
  constructor: (@root, options={}) ->
    options.history ||= window.history
    options.storage ||= window.sessionStorage
    
    @networkController = new Stacker.NetworkController
    @historyStack = Stacker.alloc(Stacker.Cards)
    @stackView = new Stacker.StackView 
      model:@historyStack, 
      el:options.container, 
      header:options.header
    @historyController = new Stacker.HistoryController(
      @historyStack, options.history, options.storage
    )
    @navigationController = new Stacker.NavigationController(
      @root, @networkController, @historyStack, @historyController
    )
