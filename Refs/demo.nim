
include karaxprelude
import jstrutils, jdict, kdom
import ../karax_utils

type
  Model = ref object
    counter: int
    textA: cstring
    textB: cstring
    messages: seq[cstring]


var vnodeMap = newJDict[cstring, (VNode, VNode)]()


proc registerAs(n: VNode, name: cstring): VNode =
  if name in vnodeMap:
    # store new candidate node
    vnodeMap[name] = (vnodeMap[name][0], n)
  else:
    vnodeMap[name] = (n, n)
  result = n


proc onClick(model: Model, ev: Event, n: VNode) =
  model.counter += 1

  if model.counter mod 5 == 0:
    swap(model.textA, model.textB)

  let idsToCheck = [cstring"textA", cstring"textB"]
  for id in idsToCheck:
    let (vnodeOld, vnodeNew) = vnodeMap[id]
    var vnode: VNode
    # If the new VNode candidate has a DOM we can store it
    if not vnodeNew.dom.isNil:
      vnodeMap[id] = (vnodeNew, vnodeNew)
      vnode = vnodeNew
    # Otherwise the old VNode must still be valid
    else:
      vnode = vnodeOld
    let node = vnode.dom
    if not node.isNil:
      let bb = node.getBoundingClientRect()
      model.messages.add(
        cstring"Element: " & id & " has width " & $bb.width
      )


proc wordSpan(spanText: cstring): VNode =
  result = buildHtml():
    span(class="word"):
      text spanText

proc view(model: Model): VNode =

  let spanA = wordSpan(model.textA).registerAs("textA")
  let spanB = wordSpan(model.textB).registerAs("textB")

  result = buildHtml():
    tdiv:
      button(onclick=curry(onClick, model)):
        text "click me"
      spanA
      spanB
      for message in model.messages:
        tdiv:
          text message


proc runMain() =
  var model = Model(
    counter: 1,
    textA: cstring"Text A",
    textB: cstring"Text B (longer than text A)",
    messages: @[]
  )

  proc renderer(): VNode =
    view(model)

  setRenderer renderer

runMain()
