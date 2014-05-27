ig.Filter = class Filter
    height: 100
    width: 900
    (@data, @property, parentElement) ->
        @element = parentElement.append \svg
            ..attr \class \filter
        @createHistogram!
        @fullDataGroup = @element.append \g
            ..attr \class \fullData
        @currentDataGroup = @element.append \g
            ..attr \class \currentData
        bins = @histogram @data
        @computeScales bins
        @drawData @fullDataGroup, bins
        @drawData @currentDataGroup, bins

    computeScales: (bins) ->
        @x = d3.scale.linear!
            ..domain [0, 80]
            ..range [0, @width]
        maxLength = Math.max ...bins.map (.y)
        @y = d3.scale.linear!
            ..domain [0, maxLength]
            ..range [0, @height]

    drawData: (parentGroup, bins) ->
        parentGroup.selectAll \rect .data bins .enter!append \rect
            ..attr \x (d, i) ~> @x i
            ..attr \height ~> @y it.y
            ..attr \width (d, i) ~> (@x 1) - 2
            ..attr \y ~> @height - @y it.y

    createHistogram: ->
        @histogram = d3.layout.histogram!
            ..value ~> it[@property]
            ..bins 40
