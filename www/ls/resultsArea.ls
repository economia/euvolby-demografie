ig.ResultsArea = class ResultsArea
    (@container, @parties) ->
        @validParties = @parties.filter (.abbr != "Nevolici")
        @bars = @container.selectAll \div.bar .data parties .enter!append \div
            ..attr \class \bar
            ..append \div  .attr \class \abbr .html (.abbr)
            ..append \div  .attr \class \sum .html (.sum)
            ..append \div  .attr \class \perc

    redraw: ->
        votes = sum @validParties.map (.sum)
        @bars.select \div.sum .html (.sum)
        @bars.select \div.perc .html -> (it.sum / votes * 100).toFixed 2
        console.log 'foo'

sum = (arr) ->
    arr.reduce do
        (prev, curr) -> prev += curr
        0
