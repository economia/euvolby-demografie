ig.ResultsArea = class ResultsArea
    (@container, @parties) ->
        @bars = @container.selectAll \div.bar .data parties .enter!append \div
            ..attr \class \bar
            ..append \div  .attr \class \abbr .html (.abbr)
            ..append \div  .attr \class \sum .html (.sum)

    redraw: ->
        @bars.select \div.sum .html (.sum)
        console.log 'foo'
