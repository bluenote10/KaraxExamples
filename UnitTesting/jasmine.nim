import future

proc describe*(description: cstring, body: () -> void) {.importc.}

proc it*(description: cstring, body: () -> void) {.importc.}

type
  JasmineRequireObj* {.importc.} = ref object
    `not`* {.importc: "not".}: JasmineRequireObj

proc expect*[T](x: T): JasmineRequireObj {.importc.}

proc toBe*[T](e: JasmineRequireObj, x: T) {.importcpp.}

#proc `not`*(e: JasmineRequireObj): JasmineRequireObj {.importc.}

