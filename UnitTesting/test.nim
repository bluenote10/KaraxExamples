
import dom, vdom, times, karax, karaxdsl, jdict, jstrutils, parseutils, sequtils
import future

static:
  echo: "Compiling..."


#[
proc karmaRunner() =
  kout("Running karma tests".cstring)

var karmaStart {.importc: "window.__karma__.start".}: () -> void
karmaStart = karmaRunner
]#

{.emit: """
describe("A suite is just a function", function() {
  var a;

  it("and so is a spec", function() {
    a = true;

    expect(a).toBe(true);
  });
});
""".}
