
include karaxprelude
import jstrutils, jdict, kdom
import ../karax_utils
import future

type
  # Elm's `model`
  Model = ref object
    items: seq[int] not nil
    counter: int

  Message = enum
    AddItem,
    RemoveItem


proc init(): Model =
  # Elm's `init`
  Model(
    items: @[],
    counter: 1,
  )


proc update(model: Model, msg: Message) =
  # Elm's `update` (but in-place)
  case msg
  of AddItem:
    let toAdd = model.counter
    model.counter += 1
    model.items.add(toAdd)
  of RemoveItem:
    if model.items.len > 0:
      model.items.setLen(model.items.len - 1)


proc view(model: Model): VNode =
  # Elm's `view`.

  proc onAdd(ev: Event, n: VNode) =
    update(model, Message.AddItem)

  proc onRemove(ev: Event, n: VNode) =
    update(model, Message.RemoveItem)

  result = buildHtml():
    tdiv:
      button(onclick=onAdd):
        text "Add item"
      button(onclick=onRemove):
        text "Remove item"
      tdiv:
        for item in model.items:
          tdiv:
            text "Item: " & $item

  # Alternatively, the message handler could be written without
  # explicitly creating procs, i.e.:
  # button(onclick=(ev: Event, n: VNode) => update(model, Message.AddItem))
  # button(onclick=(ev: Event, n: VNode) => update(model, Message.RemoveItem))


# Putting it all together
proc runMain() =
  var model = init()

  proc renderer(): VNode =
    view(model)

  setRenderer renderer

runMain()
