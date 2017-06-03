
import dom, vdom, times, karax, karaxdsl, jdict, jstrutils, parseutils, sequtils
import future


type
  KarmaTestResult = ref object
    id: cstring
    description: cstring
    suite: seq[cstring]
    log: seq[cstring]
    success: bool
    skipped: bool

  KarmaInfo = ref object
    total: int
    specs: seq[cstring]

  KarmaInstance = ref object
    result: KarmaTestResult -> void
    complete: () -> void
    error: () -> void
    info: (info: KarmaInfo) -> void

var karmaInstance {.importc: "window.__karma__".}: KarmaInstance

#var allTestResults = @[]

template suite*(name, body) {.dirty.} =
  block:
    let testSuiteName {.used.} = name
    body

template test*(name, body) {.dirty.} =
  block:
    let testName {.used.} = name
    body

template check(cond: bool) {.dirty.} =
  kout(testSuiteName.cstring, testName.cstring)
  let testResult = KarmaTestResult(
    id: testSuiteName.cstring & testName.cstring,
    description: testName.cstring,
    suite: @[testSuiteName.cstring],
    log: @[],
    success: true,
    skipped: false,
  )
  karmaInstance.result(testResult)


var
  entries: seq[cstring]
  results: seq[cstring]
  timeout: Timeout

proc reset() =
  results.add cstring"reset started"
  entries = @[cstring("0"), cstring("1"), cstring("2"), cstring("3"), cstring("4"), cstring("5") ]
  redraw()
  results.add cstring"reset finished"

proc checkOrder(order : seq[int]): bool =
  var ul = getElementById("ul")
  if ul == nil or len(ul.children) != len(order):
    return false
  var pos = 0
  for child in ul.children:
    if child.id != $order[pos]:
      return false
    inc pos
  return true

proc check1() =
  let result = checkOrder(@[0, 1, 2, 3, 4, 7, 5])
  if result:
    results.add cstring"test1 - OK"
  else:
    results.add cstring"test1 - FAIL"

# result: 0 1 2 3 4 7 5
proc test1() =
    results.add cstring"test1 started"
    entries = @[cstring("0"), cstring("1"), cstring("2"), cstring("3"), cstring("4"), cstring("5") ]
    entries.insert(cstring("7"), 5)
    redraw()
    timeout = setTimeout(check1, 20)

proc check2() =
    let result = checkOrder(@[8, 0, 1, 2, 3, 4, 7, 5])
    if result:
        results.add cstring"test1 - OK"
    else:
        results.add cstring"test2 - FAIL"

# result: 8 0 1 2 3 4 7 5
proc test2() =
    results.add cstring"test2 started"
    entries = @[cstring("0"), cstring("1"), cstring("2"), cstring("3"), cstring("4"), cstring("5") ]
    entries.insert(cstring("7"), 5)
    entries.insert(cstring("8"), 0)
    redraw()
    timeout = setTimeout(check2, 20)

proc check3() =
    let result = checkOrder(@[2, 3, 4, 1])
    if result:
        results.add cstring"test3 - OK"
    else:
        results.add cstring"test3 - FAIL"

# result: 2 3 4 1
proc test3() =
    results.add cstring"test3 started"
    entries = @[cstring("2"), cstring("3"), cstring("4"), cstring("1") ]
    redraw()
    timeout = setTimeout(check3, 20)

proc check4() =
    let result = checkOrder(@[5, 6, 7, 8])
    if result:
        results.add cstring"test4 - OK"
    else:
        results.add cstring"test4 - FAIL"

# result: 5 6 7 8
proc test4() =
    results.add cstring"test4 started"
    entries = @[cstring("5"), cstring("6"), cstring("7"), cstring("8") ]
    redraw()
    timeout = setTimeout(check4, 20)

proc check5() =
    let result = checkOrder(@[0, 1, 3, 5, 4, 5])
    if result:
        results.add cstring"test5 - OK"
    else:
        results.add cstring"test5 - FAIL"

# result: 0 1 3 5 4 5
proc test5() =
    results.add cstring"test5 started"
    entries = @[cstring("0"), cstring("1"), cstring("3"), cstring("5"), cstring("4"), cstring("5") ]
    redraw()
    timeout = setTimeout(check5, 20)

proc check6() =
    let result = checkOrder(@[])
    if result:
        results.add cstring"test6 - OK"
    else:
        results.add cstring"test6 - FAIL"

# result: empty
proc test6() =
    results.add cstring"test6 started"
    entries = @[]
    redraw()
    timeout = setTimeout(check6, 20)

proc check7() =
    let result = checkOrder(@[2])
    if result:
        results.add cstring"test7 - OK"
    else:
        results.add cstring"test7 - FAIL"
    redraw()

# result: 2
proc test7() =
    results.add cstring"test7 started"
    entries = @[cstring("2")]
    redraw()
    timeout = setTimeout(check7, 20)

proc createEntry(id: int): VNode =
  result = buildHtml():
    button(id="" & $id):
        text $id

proc createDom(): VNode =
    result = buildHtml(tdiv()):
        ul(id="ul"):
            for e in entries:
                createEntry(jstrutils.parseInt(e))
        for r in results:
            tdiv:
                text r

proc onload() =
    for i in 0..5: # 0_000:
        entries.add(cstring($i))

    var dtReset = 100
    var dtTest = 500

    var t = dtReset
    timeout = setTimeout(test1, t)
    t += dtTest
    timeout = setTimeout(reset, t)
    t += dtReset

    timeout = setTimeout(test2, t)
    t += dtTest
    timeout = setTimeout(reset, t)
    t += dtReset

    timeout = setTimeout(test3, t)
    t += dtTest
    timeout = setTimeout(reset, t)
    t += dtReset

    timeout = setTimeout(test4, t)
    t += dtTest
    timeout = setTimeout(reset, t)
    t += dtReset

    timeout = setTimeout(test5, t)
    t += dtTest
    timeout = setTimeout(reset, t)
    t += dtReset

    timeout = setTimeout(test6, t)
    t += dtTest
    timeout = setTimeout(reset, t)
    t += dtReset

    timeout = setTimeout(test7, t)


proc karmaRunner() =
  kout("Running karma tests".cstring)
  #kout(document.body)

  karmaInstance.info(KarmaInfo(total: 3))

  suite "Main":
    test "First":
      check true


  block:
    let testResult = KarmaTestResult(
      id: cstring"Test",
      description: cstring"Test 1",
      suite: @[cstring"Suite"],
      log: @[],
      success: true,
      skipped: false,
    )
    karmaInstance.result(testResult)

  block:
    let testResult = KarmaTestResult(
      id: cstring"Test",
      description: cstring"Test 2",
      suite: @[cstring"Suite"],
      log: @[],
      success: true,
      skipped: false,
    )
    karmaInstance.result(testResult)

  karmaInstance.complete()
  kout("complete called".cstring)

  let n = document.createElement("div")
  n.id = "ROOT"
  document.body.appendChild(n)
  kout(document.body)
  setRenderer createDom
  onload()


var karmaStart {.importc: "window.__karma__.start".}: () -> void
karmaStart = karmaRunner


