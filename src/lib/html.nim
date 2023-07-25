import std/macros except body, `body=`
from strutils import isUpperAscii, toLowerAscii
const tags = [
  "a", "abbr", "acronym", "address", "applet", "area", "article",
  "aside", "audio", "b", "base", "basefont", "bdi", "bdo", "big",
  "blockquote", "body", "br", "button", "canvas", "caption", "center",
  "cite", "code", "col", "colgroup", "command", "datalist", "dd",
  "del", "details", "dfn", "dialog", "div", "dir", "dl", "dt", "em",
  "embed", "fieldset", "figcaption", "figure", "font", "footer",
  "form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6",
  "head", "header", "hgroup", "html", "hr", "i", "iframe", "img",
  "input", "ins", "isindex", "kbd", "keygen", "label", "legend", "li",
  "link", "map", "mark", "menu", "meta", "meter", "nav", "nobr",
  "noframes", "noscript", "object", "ol", "optgroup", "option",
  "output", "p", "param", "pre", "progress", "q", "rp", "rt", "ruby",
  "s", "samp", "script", "section", "select", "small", "source",
  "span", "strike", "strong", "style", "sub", "summary", "sup",
  "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time",
  "title", "tr", "track", "tt", "u", "ul", "var", "video", "wbr"
]
const voidElements = [
  "area", "base", "br", "col", 
  "command", "embed", "hr", "img", 
  "input", "keygen", "link", "meta", 
  "param", "source", "track", "wbr"
]
func createElement*(tagName: string, attrs: seq[tuple[attr: string, val: string]] = @[], innerHtml: string = ""): string =
  var el = "<" & tagName
  for (attr, val) in attrs:
    el.add(" "&attr&"=\""&val&"\"")
  el.add(">")
  if tagName notin voidElements:
    el.add(innerHtml)
    el.add("<"&"/"&tagName&">")
  return el
proc escapeHtml*(text: string): string {.noSideEffect.} =
  for s in text:
    case s
      of '>':
        result.add("&gt;")
      of '<':
        result.add("&lt;")
      of '&':
        result.add("&amp;")
      of '"':
        result.add("&quot;")
      of '\'':
        result.add("&apos;")
      else: result.add(s)
proc normalizeAttr*(attr:string):string {.noSideEffect.} =
  for a in attr:
    if a.isUpperAscii:
      result.add("-")
      result.add(toLowerAscii(a))
    else: result.add(a)
proc join*(strs: varargs[string] = []): string =
  for str in strs:
    result.add(str)
macro h*(name: static string, args: varargs[untyped]): untyped =
  result = newStmtList()
  let strTypes = [nnkStrLit, nnkTripleStrLit, nnkCharLit]
  let attrs = nnkPrefix.newTree(newIdentNode("@"))
  let attr = nnkBracket.newTree()
  let innerHtml = newCall("join")
  for arg in args:
    if arg.kind == nnkExprEqExpr:
      arg[^1].expectKind(nnkStrLit)
      let attrKey = arg[0].strVal.normalizeAttr
      let attrVal = arg[^1].strVal
      attr.add(
        nnkTupleConstr.newTree(newLit(attrKey), newLit(attrVal))
      )
    elif arg.kind == nnkStmtList:
      var i: int = 0
      var node = arg
      while i < node.len:
        if node[i].kind == nnkStmtList:
          node = node[i]
          i = 0
        if node[i].kind in strTypes:
          innerHtml.add(newCall("escapeHtml", node[i]))
        else:
          innerHtml.add(newCall("$", node[i]))
        inc(i)
    else: discard
  attrs.add(attr)
  result.add(newCall("createElement", newLit(name), attrs, innerHtml))
macro createElements(): untyped =
  result = nnkStmtList.newTree()
  for tag in tags:
    var name = tag
    if tag == "div": name = "tdiv"
    var body = nnkCall.newTree(
      newIdentNode("h"),
      newLit(tag),
      newIdentNode("args")
    )
    if tag == "html": body = nnkInfix.newTree(
      newIdentNode("&"),
      newLit("<!DOCTYPE html>"),
      nnkCall.newTree(
        newIdentNode("h"),
        newLit("html"),
        newIdentNode("args")
      )
    )
    result.add(
      nnkTemplateDef.newTree(
        nnkPostfix.newTree(
          newIdentNode("*"),
          newIdentNode(name)
        ),
        newEmptyNode(),
        newEmptyNode(),
        nnkFormalParams.newTree(
          newIdentNode("untyped"),
          nnkIdentDefs.newTree(
            newIdentNode("args"),
            nnkBracketExpr.newTree(
              newIdentNode("varargs"),
              newIdentNode("untyped")
            ),
            nnkBracket.newTree(
            )
          )
        ),
        newEmptyNode(),
        newEmptyNode(),
        nnkStmtList.newTree(body)
      )
    )

#[ TODO macro component(name: static string, arguments: varargs[untyped]): untyped =
  result = newStmtList()
  let temp = nnkTemplateDef.newTree(
    nnkPostfix.newTree(
      newIdentNode("*"),
      newIdentNode(name),
      newEmptyNode(),
      newEmptyNode(),
    )
  )
  let params = nnkFormalParams.newTree(
    newIdentNode("untyped"),

  )
  for arg in arguments:
    case arg.kind:
      of nnkExprEqExpr:

      of nnkStmtList:
 ]#

# for generate templates

createElements

dumpAstGen:
  template baseHtml(arguments: varargs[untyped]): untyped =
    html(lang="en"):
      head:
        meta(charset="utf-8")
        meta(name="viewport", content="width=device-width, initial-scale=1.0")
        title: "Portfolio"
      body(dataHxGet="/view"):
        arguments