
import dom, vdom, times, karax, karaxdsl, jdict, jstrutils, parseutils, sequtils
import future
import jasmine

static:
  echo: "Compiling..."


describe("A test suite"):

  it("should work, really"):
    var a = 1
    expect(true).toBe(true)
    expect(a).toBe(1)
    expect(a).negate.toBe(2)


  let name = "asdf"

  it(name):
    discard
