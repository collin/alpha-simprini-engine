HistoryTest = setup: ->
  @controller = makeHistoryController()
  @stack = @controller.stack
  @forward = @controller.forwardStack

module "Stacker.HistoryController", HistoryTest

test "replaces history with checkpoint on creation", ->
  deepEqual @controller.history.state, Stacker.HistoryController.START

test "doesn't replace history with checkpoint if state came from HistoryController", ->
  history = new MockHistory
  storage = new MockStorage
  history.state = namespace:"Stacker.HistoryController"
  controller = new Stacker.HistoryController(new Stacker.Cards, history, storage)
  deepEqual controller.history.state, namespace:"Stacker.HistoryController"

test "pops state if starting state came from stacker", ->
  class _HistoryController extends Stacker.HistoryController
    popstate: ({state}) -> deepEqual state, namespace:"Stacker.HistoryController"

  history = new MockHistory
  storage = new MockStorage
  history.state = namespace:"Stacker.HistoryController"
  controller = new _HistoryController(new Stacker.Cards, history, storage)

module "Stacker.HistoryController#stash", HistoryTest
test "stashes stack when history changes", ->
  history = new MockHistory
  storage = new MockStorage
  history.state = namespace:"Stacker.HistoryController"
  controller = new Stacker.HistoryController(Stacker.alloc(Stacker.Cards), history, storage)
  controller.stack.add link:"HREF", html:"<html></html>", stack:controller.stack
  deepEqual JSON.parse(storage.getItem("Stacker-stash")), {
    stack: [{link: "HREF", html:"<html></html>", id:controller.stack.first().get('id'), stackId:controller.stack.id}],
    forwardStack: []
  }

module "Stacker.HistoryController#loadStash", HistoryTest
test "loads the stash", ->
  @controller.storage.setItem "Stacker-stash", JSON.stringify(
    stack: [{link: "HREF", html:"<html></html>"}],
    forwardStack: []
  )

  @controller.loadStash()
  equal @controller.stack.at(0).get('link'), "HREF"

module "Stacker.HistoryController#popstate", HistoryTest
test "noop if event has no state", ->
  equal @controller.popstate(state: null), false

test "noop unless event state is a client id", ->
  equal @controller.popstate(state: true), false

test "wipes out stack if event state is start", ->
  @stack.add(title: "itemA", stack:@stack)
  @stack.add(title: "itemB", stack:@stack)
  @stack.add(title: "itemC", stack:@stack)
  @forward.add(title:"itemD", stack:@forward)

  itemA = @stack.at(0)
  itemB = @stack.at(1)
  itemC = @stack.at(2)
  itemD = @forward.at(0)

  @controller.popstate state: Stacker.HistoryController.START
  equal @stack.length, 0
  equal @forward.length, 4
  matchModels @forward.models, [itemA, itemB, itemC, itemD]

test "shifts item into forward stack in correct order", ->
  @stack.add(title:"itemA",stack:@stack)
  @stack.add(title:"itemB",stack:@stack)
  @stack.add(title:"itemC",stack:@stack)
  @forward.add(title:"itemD",stack:@forward)

  item = @stack.at(0)
  # Items A and B will be shifter from the @stack
  #  to the @forward stack, we want them to stay in this
  #  order.
  itemA = @stack.at(1)
  itemB = @stack.at(2)
  itemC = @forward.at(0)

  @controller.popstate state:id:item.get('id')

  equal @forward.length, 3
  matchModels @forward.models, [itemA, itemB, itemC]

test "shifts item to stack if it is in the @forward stack in the correct order", ->
  @stack.add   title:"itemA", stack:@stack
  @forward.add title:"itemB", stack:@forward
  @forward.add title:"itemC", stack:@forward
  @forward.add title:"itemD", stack:@forward
  itemA = @stack.at(0)
  itemB = @forward.at(0)
  itemC = @forward.at(1)
  itemD = @forward.at(2)

  @controller.popstate state:id:itemC.get('id')

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
  @controller.stack.add item, stack:item
  deepEqual @controller.history.state, {id:item.get('id'), namespace:"Stacker.HistoryController"}

# module "Stacker.HistoryController#reset", HistoryTest
# test "resets history", ->


