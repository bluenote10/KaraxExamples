
import dom, vdom, times, karax, karaxdsl, jdict, jstrutils, parseutils, sequtils
import future
import jasmine

static:
  echo: "Compiling..."

# To clear console manually you can use:
# {.emit: "console.log('\u001b[2J\u001b[0;0H');".}

describe("A test suite"):

  it("should work"):
    var a = 1
    expect(true).toBe(true)
    expect(a).toBe(1)
    expect(a).`not`.toBe(2)

  let name = "asdf"

  it(name):
    discard
