include karaxprelude
import karaxdsl, ../karax_utils
import future, sequtils

import counter_component

type
  MainComponent = ref object
    # holds internal state like `data` in Vue
    children: seq[CounterComponent]
    sumOfCounters: int

proc render(self: MainComponent): VNode =
  result = buildHtml():
    tdiv():
      for child in self.children:
        child.render
      tdiv():
        text "Sum of counters: " & $self.sumOfCounters


proc registerCounterComponent(self: MainComponent, counterInit: int) =

  proc onInc() =
    self.sumOfCounters += 1

  proc onDec() =
    self.sumOfCounters -= 1

  self.children.add(CounterComponent(
    counter: counterInit,
    emitInc: onInc,
    emitDec: onDec,
  ))


proc runMain() =

  let initValues = @[2, 5, 3]
  let initSumOfCounters = initValues.reduce((a, b) => a + b)
  var mainComponent = MainComponent(
    sumOfCounters: initSumOfCounters,
    children: @[],
  )

  for counterInit in initValues:
    mainComponent.registerCounterComponent(counterInit)

  proc renderer(): VNode =
    mainComponent.render()

  setRenderer renderer

runMain()
