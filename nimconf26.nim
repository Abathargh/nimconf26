import nimib
import nimib/blocks
import nimiSlides
import strutils

import intro, about, what, why, experiences

nbinit(theme=revealTheme)
footer("© G. Marcello, 2026, all rights reserved.")
nb.useLatex()

template nimConfTheme*() =
  setSlidesTheme(Black)
  let nimYellow = "#FFE953"
  nb.addStyle: """
:root {
  --r-background-color: #181922;
  --r-heading-color: $1;
  --r-link-color: $1;
  --r-selection-color: $1;
  --r-link-color-dark: darken($1 , 15%)
}

.reveal ul, .reveal ol {
  display: block;
  text-align: left;
}

li::marker {
  color: $1;
  content: "»";
}

li {
  padding-left: 12px;
}
""" % [nimYellow]

nimConfTheme()
intro()
about()
what()
why()
experiences()
nbSave()
