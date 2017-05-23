
include karaxprelude
import jstrutils, jdict, dom
import future, sequtils, random


proc x(n: Node): float {.importcpp: "#.x", nodecl.}
proc y(n: Node): float {.importcpp: "#.y", nodecl.}

#proc transform(s: Style, transform: cstring) {.importcpp: "#.transform = #", nodecl.}

type
  IdentifyableString = object
    s: string
    id: int

  Position = object
    x: float
    y: float

  Model = ref object
    text: seq[IdentifyableString]

    positions: JDict[string, Position]

  EventHandler = (Event, VNode) -> void
  EventHandlerModel = (Model, Event, VNode) -> void


proc curry(handler: EventHandlerModel, model: Model): EventHandler =
  result = (ev: Event, n: VNode) => handler(model, ev, n)

proc curry(handler: Model -> void, model: Model): (() -> void) =
  result = () => handler(model)


proc onClick(model: Model, ev: Event, n: VNode) =
  #kout(ev)
  #kout(model)

  for word in model.text:
    let id = "word-" & $word.id
    let element = getElementById(id)
    if not element.isNil:
      let boundingBox = element.getBoundingClientRect()
      # kout(boundingBox)
      model.positions[id] = Position(
        x: boundingBox.left.toFloat,
        y: boundingBox.top.toFloat,
      )

  # kout(model.positions)
  shuffle(model.text)


proc startTransform(element: Element): () -> void =
  result = proc() =
    #kout(element)
    element.classList.add("animate-on-transform")
    element.style.transform = cstring""


proc postRenderCallback(model: Model) =
  kout("post render".cstring)

  for word in model.text:
    var id = "word-" & $word.id
    var element = getElementById(id)
    if not element.isNil:

      if model.positions.contains(id):
        let boundingBox = element.getBoundingClientRect()
        let oldPos = model.positions[id]
        let newPos = Position(
          x: boundingBox.left.toFloat,
          y: boundingBox.top.toFloat,
        )
        let dx = oldPos.x - newPos.x
        let dy = oldPos.y - newPos.y
        let transform = "translateX(" & $dx & "px) translateY(" & $dy & "px)"
        # kout(oldPos, newPos)

        element.style.transform = transform.cstring

        reqFrame(startTransform(element))


proc view(model: Model): VNode =
  result = buildHtml():
    tdiv:
      button(class="button", onclick=curry(onClick, model)):
        text "Shuffle Text"
      tdiv:
        for word in model.text:
          let id = "word-" & $word.id
          span(class="word", id=id):
            text word.s.cstring


proc runMain() =

  # sucks that `pairs` can't be chained. Would be nice to write:
  # let text = @["Play", "with", "matches,", "you", "get", "burned."]
  #               .cycle(10)
  #               .pairs()
  #               .map((i, w) => IdentifyableString(s: w, id: i))
  let text = toSeq(pairs(@["Play", "with", "matches,", "you", "get", "burned."].cycle(10))).map(
    t => IdentifyableString(s: t.val, id: t.key)
  )

  var model = Model(
    text: text,
    positions: newJDict[string, Position]()
  )

  proc renderer(): VNode =
    view(model)

  setRenderer renderer, curry(postRenderCallback, model)

runMain()

