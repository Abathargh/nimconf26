import nimib

template experiences*: untyped =
  slide:
    nbText: "## using nim on tiny computers"
    slide:
      nbText: "This code will run on both an x64 server and an avr mcu"
      nbCodeSkip:
        proc main =
          while true: discard
        main()
    slide:
      nbText "compiling to c = write nim for almost any platform"
      nbCodeSkip:
        # config.nims
        switch("os", "standalone")
        switch("cpu", "avr")
        switch("passC", "-mmcu=atmega328p")
        switch("passL", "-mmcu=atmega328p")
        switch("avr.standalone.gcc.options.linker", "-static")
        switch("avr.standalone.gcc.exe", "avr-gcc")
        switch("avr.standalone.gcc.linkerexe", "avr-gcc")
    slide:
     nbText: "The compiler is identified by the cpu.os.compiler name"
     unorderedList:
       listItem: nbText: "compiler executable: exe property."
       listItem: nbText: "linker executable: linkerexe property."

    slide:
      nbText "foreign function interface"
      nbText: "super easy to use, can be semi-automated (c2nim, futhark)"
      nbCodeSkip:
        proc delay_ms(us: float32)
          {.importc: "_delay_ms", header: "util/delay.h".}
        proc main =
          while true:
            delay_ms(1000)
        main()
    slide:
      nbText: "low-level constructs"
      nbText: "asm blocks, ptr, etc."
    slide:
      nbText "metaprogramming"
      unorderedList:
        listItem: nbText: "compile-time functions"
        listItem: nbText: "generics"
    slide:
      nbCodeSkip:
        template vectorDecl(n: int): string =
          "$1  __vector_" & $n &
          "$3 __attribute__((__signal__,__used__,__externally_visible__));" &
          "$1 __vector_" & $n & "$3"

    slide:
      nbCodeSkip:
        macro isr*(v: static[VectorInterrupt], p: untyped): untyped =
          var pnode = p
          if p.kind == nnkStmtList:
            pnode = p[0]
          expectKind(pnode, nnkProcDef)
          addPragma(pnode, newIdentNode("exportc"))
          addPragma(pnode, newNimNode(nnkExprColonExpr).add(
              newIdentNode("codegenDecl"),
              newLit(vectorDecl(ord(v)))))
          pnode
    slide:
      nbCodeSkip:
        proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
          # do stuff when the timer0 compare A interrupt gets triggered
          discard

  slide:
    nbText: "## writing a library: avr_io"
    nbText  "I used lots of these tricks when writing avr_io"
    nbText: "github.com/Abathargh/avr_io"
    nbText: "as of v0.7.0 (feb 26) support all atmega/attiny mcus"
    nbText: "(-avrxmega and avr1)"

  slide:
    nbText: "## tips for application code"
    slide: nbText: "some thoughts and experiences about using nim for application development"
    slide:
      nbText: "arc memory managemnt"
      unorderedList:
        listItem: nbText: "deterministic"
        listItem: nbText: "low cost in size, arc almost free if not using ref-types"
        listItem: nbText: "haven't measured but size diffs not too bad wrt to -mm:none"

    slide:
      nbText: "when needed, you can squeeze some KB with:"
      nbCodeSkip:
        switch("gc", "none")
        switch("opt", "size")
        switch("define", "danger")
        switch("exceptions", "quirky")

    slide:
      nbText: "## object variants"
      unorderedList:
        listItem: nbText: "safer tagged unions from C"
        listItem: nbText: "space efficient"
        listItem: nbText: "must recreate object when switchint tag"
        listItem: nbText: "raise exception when accessing a non-active field"
    slide:
      nbCodeSkip:
        type
          CmdKind* = enum
            SetBpm
            SetValue
            SetAmplitude
            SetEnvelope
    slide:
      nbCodeSkip:
        type Command* = object
          case kind*: CmdKind
          of SetBpm:
            bpm*:       uint16
          of SetValue:
            value*:     NoteValue
          of SetAmplitude:
            amp_chan*:  uint8
            amplitude*: uint8
          of SetEnvelope:
            envelope*:  EnvelopeShape
            frequency*: uint16
    slide:
      unorderedList:
        listItem: nbText: "you can write custom panic handles to catch access errors"
        listItem: nbText: "needs `-mm:arc --define:useMalloc`"
    slide:
      nbCodeSkip:
        import avr_io
        proc exit(code: int) {.importc, header: "<stdlib.h>", cdecl.}
        proc delay_ms(ms: float32) {.importc: "_delay_ms", header: "<util/delay.h>".}
        {.push stack_trace: off, profiler:off.}
        proc rawoutput(s: string) = usart0.write_string_ln(s)
        proc panic(s: string) =
          rawoutput(s)
          portb.as_output_pin(5)
          while true:
            portb.toggle_pin(5)
            delay_ms(500)
          exit(1)
        {.pop.}
    slide:
      nbText: "for added safety, you can verify this proprierty at comptime"
      nbCodeSkip:
        switch("warning", "ProveField:on")
        switch("warningAsError", "ProveField:on")

    slide:
      nbText: "## no allocations"
      nbText: "sometimes you want to keep allocations to a minimum"
      unorderedList:
        listItem: nbText "var parameters (+ {.byref.})"
        listItem: nbText "non-owning views (toOpenArray)"

    slide:
      nbText: "## non-owning views"
      nbCodeskip:
        type ArraySlice* = object
          data: ptr UncheckedArray[char]
          beg, fin, cap: int

        template `[]`*(slice: ArraySlice, idx: Natural): char =
          slice.data[(slice.beg + idx.int) mod slice.cap]

        proc slice*[N: static int](buf: array[N, char], size: int): ArraySlice =
          result.data = cast[ptr UncheckedArray[char]](addr buf[0])
          result.beg  = 0
          result.fin  = size - 1
          result.cap = N

    slide:
      nbText: "## move it to comptime"
      nbCodeSkip:
        const
          ErrorStrings = (proc(): array[ErrorCode.high.ord + 1, string] =
            for i in 0..ErrorCode.high.ord:
              result[i] = symbolName(cast[ErrorCode](i))
          )()

    slide:
      nbText: "## macro-based metaprogramming"
      unorderedList:
        listItem: nbText: "very powerful but hard to get it right"
        listItem: nbText: "best used in library code"
        listItem: nbText: "always prefer templates and generics when possible"

  slide:
    nbText: "## what does the future hold"
    unorderedList:
      listItem: nbText: "experimenting with atlas"
      listItem: nbText: "nimony - better tooling?"

  slide:
    nbText: "## Thanks!"
    nbText: "## Grazie per l'attenzione!"
