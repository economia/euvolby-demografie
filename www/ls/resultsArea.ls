colors =
    KSCM     : \#e3001a
    CSSD     : \#f29400
    TOP      : \#7c0042
    KDU      : \#FFE03E
    Pirati   : \#333333
    ANO      : \#282560
    ODS      : \#006ab3
    SZ       : \#00AD00
    Svobodni : \#005B46
    Usvit    : \#F49E00
    Ostatni  : \#888888

names =
    KSCM     : \KSČM
    CSSD     : \ČSSD
    TOP      : \TOP
    KDU      : \KDU
    Pirati   : \Piráti
    ANO      : \ANO
    ODS      : \ODS
    SZ       : \SZ
    Svobodni : \Svob.
    Usvit    : \Úsvit
    Ostatni  : \Ostatni

ig.ResultsArea = class ResultsArea
    height: 150
    width: 965
    padding: [10 0 40 15]
    (container, @parties) ->
        @validParties = @parties.filter (.abbr != "Nevolici")

        @element = container.append \svg
            ..attr \height @height + @padding.0 + @padding.2
            ..attr \width @width + @padding.1 + @padding.3
            ..attr \class \resultsArea

        @canvas = @element.append \g
            ..attr \transform "translate(#{@padding.3}, #{@padding.0})"

        @y = d3.scale.linear!
            ..domain [0 0.25]
            ..range [0 @height]

        votes = sum @validParties.map (.sum)
        @validParties.sort (a, b) ->
            | a.abbr == \Ostatni => +1
            | b.abbr == \Ostatni => -1
            | otherwise => b.sum - a.sum

        @validParties.forEach ->
            it.currentPercent = it.defaultPercent = it.sum / votes
        @parties = @canvas.selectAll \g.party .data @validParties .enter!append \g
            ..attr \class \party
            ..attr \transform (d, i) -> "translate(#{i * 80}, 0)"
        @defaultValues = @parties.append \rect
            ..attr \class \default
            ..attr \height ~> @y it.defaultPercent
            ..attr \y ~> @height - @y it.defaultPercent
            ..attr \width 80 - 30
            ..attr \fill ~> colors[it.abbr]
        @currentValues = @parties.append \rect
            ..attr \class \diff
            ..attr \height ~> @y it.defaultPercent
            ..attr \y ~> @height - @y it.defaultPercent
            ..attr \width 80 - 30

        @canvas.append \line
            ..attr \class \zeroLine
            ..attr \x1 0 - @padding.3
            ..attr \x2 @width + @padding.1
            ..attr \y1 @height
            ..attr \y2 @height

        @parties.append \text
            ..attr \class \partyName
            ..html ~> names[it.abbr]
            ..attr \y 18# @height + 20
            ..attr \x 25
            ..attr \width 80
            ..attr \text-anchor \middle

        @partyResult = @parties.append \text
            ..attr \class \partyResult
            ..html ~> "#{(it.defaultPercent * 100).toFixed 2 .replace "." ","} %"
            ..attr \y 35
            ..attr \x 25
            ..attr \width 80
            ..attr \text-anchor \middle

        @partyDifference = @parties.append \text
            ..attr \class "partyDifference"
            ..html ~> ""
            ..attr \y 50
            ..attr \x 22
            ..attr \width 80
            ..attr \text-anchor \middle

    redraw: ->
        votes = sum @validParties.map (.sum)
        @validParties.forEach ->
            it.currentPercent = it.sum / votes
        @currentValues
            ..classed \positive ~> it.currentPercent > it.defaultPercent
            ..attr \height ~>
                @y Math.abs it.currentPercent - it.defaultPercent
            ..attr \y ~>
                if it.currentPercent > it.defaultPercent
                    @height - @y it.currentPercent
                else
                    @height
        @defaultValues
            ..attr \y ~>
                if it.currentPercent > it.defaultPercent
                    @height - @y it.defaultPercent
                else
                    @height - @y it.currentPercent
        @partyResult.html ~> "#{(it.currentPercent * 100).toFixed 2 .replace "." ","} %"
        @partyDifference.html ~>
            diff = it.currentPercent - it.defaultPercent
            str = if diff > 0 then "+" else "-"
            str += " #{(Math.abs diff * 100).toFixed 2 .replace "." ","} %"
            str



sum = (arr) ->
    arr.reduce do
        (prev, curr) -> prev += curr
        0
