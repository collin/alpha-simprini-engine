HistoryTest = setup: ->
  @controller = makeHistoryController()
  @stack = @controller.stack
  @forward = @controller.forwardStack

module "Stacker.HistoryController", HistoryTest

test "replaces history with checkpoint on creation", ->
  deepEqual @controller.history.state, Stacker.HistoryController.START

module "Stacker.HistoryController#popstate", HistoryTest
test "noop if event has no state", ->
  equal @controller.popstate(state: null), false

test "noop unless event state is a client id", ->
  equal @controller.popstate(state: true), false

test "wipes out stack if event state is start", ->
  @stack.add(title: "itemA")
  @stack.add(title: "itemB")
  @stack.add(title: "itemC")
  @forward.add(title:"itemD")

  itemA = @stack.at(0)
  itemB = @stack.at(1)
  itemC = @stack.at(2)
  itemD = @forward.at(0)

  @controller.popstate state: Stacker.HistoryController.START
  equal @stack.length, 0
  equal @forward.length, 4
  matchModels @forward.models, [itemA, itemB, itemC, itemD]

test "shifts item into forward stack in correct order", ->
  @stack.add(title:"itemA")
  @stack.add(title:"itemB")
  @stack.add(title:"itemC")
  @forward.add(title:"itemD")

  item = @stack.at(0)
  # Items A and B will be shifter from the @stack
  #  to the @forward stack, we want them to stay in this
  #  order.
  itemA = @stack.at(1)
  itemB = @stack.at(2)
  itemC = @forward.at(0)

  @controller.popstate state:cid:item.cid

  equal @forward.length, 3
  matchModels @forward.models, [itemA, itemB, itemC]

test "shifts item to stack if it is in the @forward stack in the correct order", ->
  @stack.add   title:"itemA"
  @forward.add title:"itemB"
  @forward.add title:"itemC"
  @forward.add title:"itemD"
  itemA = @stack.at(0)
  itemB = @forward.at(0)
  itemC = @forward.at(1)
  itemD = @forward.at(2)

  @controller.popstate state:cid:itemC.cid

  equal @forward.length, 1
  matchModels @stack.models, [itemA, itemB, itemC]

test "triggers stack change event", ->
  @stack.on 'change', -> ok true
  @controller.popstate state: Stacker.HistoryController.START

module "Stacker.HistoryController#clearForwardStack", HistoryTest
test "clears the forward stack", ->
  @controller.forwardStack.add {}
  @controller.clearForwardStack()
  equal @controller.forwardStack.length, 0

test "clears forward stack when stack is added to", ->
  @controller.clearForwardStack = -> ok true
  @controller.stack.trigger('add')

module "Stacker.HistoryController#pushState", HistoryTest
test "pushes state to history", ->
  item = new Stacker.Card link:"HREF"
  @controller.stack.add item
  deepEqual @controller.history.state, {cid:item.cid}

# module "Stacker.HistoryController#reset", HistoryTest
# test "resets history", ->

