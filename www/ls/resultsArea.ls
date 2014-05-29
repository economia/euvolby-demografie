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
    Nevolici : \#333333

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
    Nevolici : \Účast

ig.ResultsArea = class ResultsArea
    height: 150
    width: 965
    padding: [10 0 40 15]
    (container, @parties) ->
        @validParties = @parties.slice 0

        @element = container.append \svg
            ..attr \height @height + @padding.0 + @padding.2
            ..attr \width @width + @padding.1 + @padding.3
            ..attr \class \resultsArea

        @canvas = @element.append \g
            ..attr \transform "translate(#{@padding.3}, #{@padding.0})"

        @y = d3.scale.linear!
            ..domain [0 0.25]
            ..range [0 @height]

        @sum = computePercent @validParties, "defaultPercent"

        @validParties.sort (a, b) ->
            | a.abbr == \Nevolici => +1
            | b.abbr == \Nevolici => -1
            | a.abbr == \Ostatni => +1
            | b.abbr == \Ostatni => -1
            | otherwise => b.sum - a.sum

        @parties = @canvas.selectAll \g.party .data @validParties .enter!append \g
            ..attr \class \party
            ..attr \transform (d, i) -> "translate(#{i * 73}, 0)"
        @defaultValues = @parties.append \rect
            ..attr \class \default
            ..attr \height ~> @y it.defaultPercent
            ..attr \y ~> @height - @y it.defaultPercent
            ..attr \width 73 - 30
            ..attr \fill ~> colors[it.abbr]
        @currentValues = @parties.append \rect
            ..attr \class \diff
            ..attr \height ~> @y it.defaultPercent
            ..attr \y ~> @height - @y it.defaultPercent
            ..attr \width 73 - 30

        @canvas.append \line
            ..attr \class \zeroLine
            ..attr \x1 0 - @padding.3
            ..attr \x2 @width + @padding.1 - 105
            ..attr \y1 @height
            ..attr \y2 @height

        @parties.append \text
            ..attr \class \partyName
            ..text ~> names[it.abbr]
            ..attr \y 3# @height + 20
            ..attr \x 22

        @partyResult = @parties.append \text
            ..attr \class \partyResult
            ..text ~> "#{(it.defaultPercent * 100).toFixed 2 .replace "." ","} %"
            ..attr \y 20
            ..attr \x 22

        @partyDifference = @parties.append \text
            ..attr \class "partyDifference"
            ..text ~> ""
            ..attr \y 35
            ..attr \x 21

        totalsGroup = @canvas.append \g
            ..attr \class \totals
            ..attr \transform "translate(910, 0)"

        totalsGroup.append \text
            ..text "Vybráno"
            ..attr \y 2
        @totalPercent = totalsGroup.append \text
            ..attr \class \percent
            ..text "100 %"
            ..attr \y 20
        @disableButton = totalsGroup.append \text
            ..attr \class \disableButton
            ..text "všichni voliči"
            ..attr \y 35

        @canvas.append \text
            ..attr \class \zero
            ..text "0"
            ..attr \x -14
            ..attr \y 165

    redraw: ->
        people = computePercent @validParties, 'currentPercent'
        totalPercentStr = people / @sum * 100
        if totalPercentStr == 100
            totalPercentStr = "100"
        else if totalPercentStr < 1 or totalPercentStr > 99
            totalPercentStr .= toFixed 2
        else if totalPercentStr < 10 or totalPercentStr > 95
            totalPercentStr .= toFixed 1
        else
            totalPercentStr .= toFixed 0
        totalPercentStr .= replace "." ","

        @totalPercent.text "#totalPercentStr %"
        @disableButton.classed \active people != @sum
        if people != @sum
            @disableButton.text "[zrušit filtry]"
            @disableButton.attr \dy 50
        else
            @disableButton.text "všichni voliči"
            @disableButton.attr \dy 0



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
        @partyResult.text ~> "#{(it.currentPercent * 100).toFixed 2 .replace "." ","} %"
        @partyDifference.text ~>
            diff = it.currentPercent - it.defaultPercent
            str =
                | diff > 0 => "+"
                | diff < 0 => "-"
                | otherwise => "±"
            str += " #{(Math.abs diff * 100).toFixed 2 .replace "." ","} %"
            str


computePercent = (parties, type) ->
    votes = 0
    people = 0
    for {sum, abbr} in parties
        people += sum
        votes += sum if abbr isnt \Nevolici

    for party in parties
        if party.abbr isnt \Nevolici
            party[type] = party.sum / votes
        else
            party[type] = 1 - party.sum / people

    people
