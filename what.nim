import nimib

template what*(): untyped =
  slide:
    nbText: "## contents of this talk"
    unorderedList:
      listItem: nbText: "last year i talked about avr_io"
      listItem: nbText: "using nim to develop software for microcontrollers"
      listItem: nbText: "experiences with writing embedded libraries and apps"
      listItem: nbText: "tips and configurations"
      listItem: nbText: "the future"
