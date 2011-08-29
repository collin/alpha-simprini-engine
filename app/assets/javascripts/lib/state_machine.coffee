StateMachine = new AS.Mixin
  class_methods:
    event: (name, options) ->
      @events ?= []
      options.name = name
      @events.push options
      
    to_dot: () ->
      dot = ["digraph G {"]
     
      for event in @events
        for state in event.from.split " "
          for trigger in event.via.split " "
            dot.push "  #{state} -> #{event.to} [label=\"#{trigger}\"];"
    
      dot.push "}"
      dot.join("\n")
    
  instance_methods:
    bind_state_machine_to: (object) ->
      for event in @constructor.events
        for trigger in event.via.split(" ")
          object.bind trigger, (event) => @process(event)
      
    process: (event) ->
      state_event = _.detect @constructor.events, (_event) =>
        _event.via.match(event.type) and _event.from.match(@state)
        
      if state_event
        @["before_#{state_event.name}}"]?(event)
        console.log "transition from #{@state} to #{state_event.to}"
        @state = state_event.to
        @["after_#{state_event.name}"]?(event)
