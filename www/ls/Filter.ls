ig.Filter = class Filter
    height: 100
    width: 400
    (@data, @property, parentElement) ->
        @element = parentElement.append \svg
            ..attr \class \filter
            ..attr \height @height
            ..attr \width @width
        @createHistogram!
        @fullDataGroup = @element.append \g
            ..attr \class \fullData
        @currentDataGroup = @element.append \g
            ..attr \class \currentData
        bins = @histogram @data
        @computeScales bins
        @drawData @fullDataGroup, bins
        @currentDataBars = @drawData @currentDataGroup, bins
        @prepareBrush!

    onBrush: ->
        extent = @brush.extent!
        @onChange @property, extent

    setCurrentData: (currentData) ->
        @currentDataBars
            ..attr \height ~>
                count = 0
                for item in it
                    count++ if item.valid
                it.height = @y count
            ..attr \y ~> @height - it.height


    computeScales: (bins) ->
        minX = bins[0].x
        maxX = bins[* - 1].x + bins[* - 1].dx
        @x = d3.scale.linear!
            ..domain [minX, maxX]
            ..range [0, @width]
        @histogram.range [minX, maxX]

        maxLength = Math.max ...bins.map (.y)
        @y = d3.scale.linear!
            ..domain [0, maxLength]
            ..range [0, @height]

    drawData: (parentGroup, bins) ->
        parentGroup.selectAll \rect .data bins .enter!append \rect
        parentGroup.selectAll \rect
            ..attr \x ~> @x it.x
            ..attr \height ~> @y it.y
            ..attr \width ~> (@x it.dx) - 2
            ..attr \y ~> @height - @y it.y


    createHistogram: ->
        @histogram = d3.layout.histogram!
            ..value ~> it[@property]
            ..bins 40
        range = @histogram.range!

    prepareBrush: ->
        @brush = d3.svg.brush!
            ..x @x
            ..on \brush @~onBrush
        if @property == \verici
            @brush.extent [30 80]
        brushG = @element.append \g
            ..attr \class \brush
            ..call @brush
            ..selectAll \.resize
                ..append \rect
                    ..attr \class \border
                    ..attr \width 1

            ..selectAll \rect
                ..attr \height @height
        if @property == \verici
            <~ setTimeout _, 10
            @brush.event brushG
