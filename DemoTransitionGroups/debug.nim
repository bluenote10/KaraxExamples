import future, sequtils

proc mapper(xy: (int, int)): int =
  result = x

var s = newSeq[(int, int)]()
var sMapped1 = map(s, mapper)
var sMapped2 = s.map(mapper)
var sMapped3 = s.map(proc(x: int, y: int): int = x)
var sMapped4 = s.map((x, y) => x)
var sMapped5 = s.map((x: int, y: int) => x)

#[

when false:
  block:
    var s = newSeq[(int, int)]()
    for a, b in s:
      discard

  block:
    var s = newSeq[(int, int, int)]()
    s &= (1, 2, 3)
    for a, b, c in items(s):
      echo a, b, c
      discard


#var s = newSeq[int]()
#var sMod = s.map((a: int) => a)

]#
