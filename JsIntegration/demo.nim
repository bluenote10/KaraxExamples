
const s = staticRead("demo.js")
{.emit: s.}

proc jsHelloWorld(x: int): int {.importc, nodecl.}

discard jsHelloWorld(1)
