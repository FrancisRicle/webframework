import lib/html
template tdmain(args: varargs[untyped]): untyped =
  tdiv(role="main"):
    nav:
      ul(role="menu"):
        li:"acerca de"
        li: "contacto"
        li: "redes"
    h1: "Bienvenido >"
    args
template baseHtml(arguments: varargs[untyped]): untyped =
  html(lang="en"):
    head:
      meta(charset="utf-8")
      meta(name="viewport", content="width=device-width, initial-scale=1.0")
      title: "Portfolio"
    body(dataHxGet="/view"):
      arguments
const base1 = html(lang="en"):
    head:
      meta(charset="utf-8")
      meta(name="viewport", content="width=device-width, initial-scale=1.0")
      title: "Portfolio"
    body(dataHxGet="/view"):
      tdiv(role="main"):
        nav:
          ul(role="menu"):
            li:"acerca de"
            li: "contacto"
            li: "redes"
        h1: "Bienvenido >"
        hr
        h2: 2
const base2 = baseHtml:
  tdiv(role=$444):
    nav:
      ul(role="menu"):
        li:"acerca de"
        li: "contacto"
        li: "redes"
    h1: "Bienvenido >"
    hr
    h2: 2
const base3 = baseHtml:
  tdmain:
    hr
    h2: 2

echo base1 == base2
echo base2 == base3