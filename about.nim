import nimib

template about*: untyped =
  slide:
    nbText: "## super fast about me"
    slide:
      unorderedList:
        listItem: nbText: "Gianmarco, from Italy"
        listItem: nbText: "Embedded Software Engineer"
        listItem: nbText: "Love open source & work in it"
        listItem: nbText: "Resident AVR enthusiast"
        listItem: nbText: "Sometimes writing on antima.it"
    slide:
      nbText: "### nim community"
      unorderedList:
        listItem: nbText: "main nim project: avr_io, avrman"
        listItem: nbText: "minor enablement for 8-bit systems in the compiler"
        listItem: nbText: "currently experimenting with nimony"
    slide:
      nbText: "### contacts"
      unorderedList:
        listItem: nbText: "g.marcello@antima.it"
        listItem: nbText: "github.com/Abathargh"
