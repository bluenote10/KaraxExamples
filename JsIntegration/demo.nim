
# Embed JS code at compile time
const s = staticRead("demo.js")
{.emit: s.}

# Write corresponding function signatures
proc jsHelloWorld(x: int): int {.importc, nodecl.}

discard jsHelloWorld(1)
