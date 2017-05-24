
include karaxprelude
import jstrutils, jdict, dom
import future, sequtils, random


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

  for word in model.text:
    let id = "word-" & $word.id
    let element = getElementById(id)
    if not element.isNil:
      let boundingBox = element.getBoundingClientRect()
      model.positions[id] = Position(
        x: boundingBox.left.toFloat,
        y: boundingBox.top.toFloat,
      )

  shuffle(model.text)


proc startTransform(elements: seq[Element]): () -> void =
  result = proc() =
    for element in elements:
      element.classList.add("animate-on-transform")
      element.style.transform = cstring""


proc postRenderCallback(model: Model) =
  kout("post render".cstring)

  var deltas = newSeq[(Element, float, float)]()

  # using a two pass approach to avoid layout thrashing
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
        deltas &= (element, dx, dy)

  # second pass: apply transforms
  for element, dx, dy in deltas.items():
    let transform = "translateX(" & $dx & "px) translateY(" & $dy & "px)"
    # kout(oldPos, newPos)
    element.style.transform = transform.cstring

  # request start of animation for affected elements
  let elements = deltas.map(x => x[0])
  reqFrame(startTransform(elements))


proc view(model: Model): VNode =
  result = buildHtml():
    tdiv:
      button(class="button", onclick=curry(onClick, model)):
        text "Shuffle"
      tdiv:
        for word in model.text:
          let id = "word-" & $word.id
          span(class="word", id=id):
            text word.s.cstring


proc runMain() =

  # A pity that `pairs` can't be chained. Would be nice to write:
  # let text = textOrig.cycle(10)
  #                    .pairs()
  #                    .map((i, w) => IdentifyableString(s: w, id: i))
  let textOrig = @["Entropy", "isn’t", "what", "it", "used", "to", "be."]
  let text = toSeq(pairs(textOrig.cycle(10))).map(
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

