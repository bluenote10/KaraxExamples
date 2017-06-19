include karaxprelude
import karaxdsl
import future


type
  CounterComponent* = ref object
    # holds internal state like `data` in Vue
    counter*: int
    emitInc*: () -> void
    emitDec*: () -> void


proc render*(self: CounterComponent): VNode =

  proc onInc(ev: Event, n: VNode) =
    self.counter += 1
    self.emitInc()

  proc onDec(ev: Event, n: VNode) =
    self.counter -= 1
    self.emitDec()

  result = buildHtml():
    tdiv():
      tdiv():
        text "Counter value: " & $self.counter
      button(onclick=onInc):
        text "inc"
      button(onclick=onDec):
        text "dec"
