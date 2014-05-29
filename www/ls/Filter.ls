propertyNames =
    mimo_byty          : "Podíl lidí mimo byty"
    verici             : "Podíl věřících"
    vek_prumer         : "Věkový průměr"
    vdani              : "Podíl vdaných"
    vzdelani_zakladni  : "Lidé s pouze základním vzděláním"
    vzdelani_stredni   : "Lidé se střední školou bez maturity"
    vzdelani_maturita  : "Lidé s maturitou"
    vzdelani_vysoka    : "Lidé s vysokou školou"
    prac_studenti      : "Podíl pracujících studentů"
    nikdy_nezamestnani : "Podíl nikdy nezaměstnaných"
    studenti           : "Podíl studentů"
    nezamestnani       : "Podíl nezaměstnaných"
    zamestnani         : "Podíl zaměstnanců"
    podnikatele        : "Podíl podnikatelů"
    osvc               : "Podíl OSVČ"
    ucastPrc           : "Volební účast"

descriptions =
    nikdy_nezamestnani : "Lidé, kteří nikdy neměli práci"
    podnikatele : "Zaměstnavatelé, vlastníci firem"
    verici: "Tažením myši vyberete část grafu, která vás zajímá"

ig.Filter = class Filter
    height: 100
    width: 430
    padding: [45 4 20 1]
    (@data, @property, parentElement) ->
        @localSortedData = @data.slice 0
            .sort (a, b) ~> a[@property] - b[@property]
        @element = parentElement.append \svg
            ..attr \class "filter #{@property}"
            ..attr \height @height + @padding.0 + @padding.2
            ..attr \width @width + @padding.1 + @padding.3
        @axesGroup = @element.append \g
            ..attr \class \axis
        @canvas = @element.append \g
            ..attr \transform "translate(#{@padding.3}, #{@padding.0})"
        @fullDataGroup = @canvas.append \g
            ..attr \class \fullData
        @currentDataGroup = @canvas.append \g
            ..attr \class \currentData
        @sqrtAxis = @property in <[mimo_byty vzdelani_zakladni]>
        @createHistogram!
        bins = @histogram @localSortedData
        @computeScales bins
        @drawData @fullDataGroup, bins
        @currentDataBars = @drawData @currentDataGroup, bins
        @drawMedian @canvas, @localSortedData
        @currentMedian = @drawMedian @canvas, @localSortedData
            ..classed \currentData yes
        @prepareBrush!
        @drawAxes!
        @element.append \text
            ..attr \class \heading
            ..text propertyNames[@property]
            ..attr \y 16
            ..attr \x 0
        @selectionText = @element.append \text
            ..attr \class \selection
            ..attr \y 32
        if descriptions[@property] => @selectionText.text that
        @cancelSelectionText = @element.append \text
            ..attr \class \cancelSelection
            ..text "[zrušit výběr]"
            ..attr \y 32
            ..attr \dx 6
            ..on \click @~cancelBrush


    onBrush: ->
        extent = @brush.extent!
        return if extent.0 is extent.1
        @brushExtentLine
            ..attr \x1 @x extent.0
            ..attr \x2 @x extent.1
        @xAxisTexts.classed \active ~> extent.0 <= it <= extent.1
        if @sqrtAxis
            extent .= map -> it^2
        if @property == \vek_prumer
            @selectionText.text "Vybrány pouze obce mezi #{extent.0.toFixed 1} – #{extent.1.toFixed 1}"
        else
            @selectionText.text "Vybrány pouze obce mezi #{extent.0.toFixed 1} % – #{extent.1.toFixed 1} %"
        {width:textWidth} = @selectionText.0.0.getBBox!
        @cancelSelectionText.attr \x textWidth
        @onChange @property, extent

    cancelBrush: ->
        extent = @brush.extent!
        return if extent.0 == extent.1 == 0
        @brush.clear!
        @brushG.call @brush
        @selectionText.text ""
        @xAxisTexts.classed \active no
        @cancelSelectionText.attr \x null
        @onChange @property, null

    setCurrentData: (currentData, currentDataLength) ->
        medianPosition = Math.round currentDataLength / 2
        totalCount = 0
        subMedianInvalidCount = 0
        @currentDataBars
            ..attr \transform ~>
                count = 0
                for item in it
                    if item.valid
                        totalCount++
                        count++
                    else if totalCount < medianPosition
                        subMedianInvalidCount++
                height = @y count
                percentage = height / @height
                offset = @height - height
                s = "translate(0, #offset), scale(1, #percentage)"

        median = @localSortedData[medianPosition + subMedianInvalidCount]
        x = @x median[@property]
        @currentMedian
            ..attr \x1 x
            ..attr \x2 x

    computeScales: (bins) ->
        minX = bins[0].x
        maxX = bins[* - 1].x + bins[* - 1].dx
        @x = d3.scale.linear!
        @x
            ..domain [minX, maxX]
            ..range [0, @width]
        @histogram.range [minX, maxX]

        maxLength = Math.max ...bins.map (.y)
        @y = d3.scale.linear!
            ..domain [0, maxLength]
            ..range [0, @height]

    drawData: (parentGroup, bins) ->
        parentGroup.selectAll \rect .data bins .enter!append \rect
            ..attr \x ~> @x it.x
            ..attr \height @height
            ..attr \width -2 + @x bins.1.x
            ..attr \transform ~>
                height = @y it.y
                scale = height / @height
                offset = @height - height
                "translate(0, #offset), scale(1, #scale)"
            ..attr \y 0

    drawMedian: (parentGroup, sortedData) ->
        median = sortedData[Math.round sortedData.length / 2]
        x = @x median[@property]
        parentGroup.append \line
            ..attr \class \median
            ..attr \x1 x
            ..attr \x2 x
            ..attr \y1 -5
            ..attr \y2 @height


    createHistogram: ->
        @histogram = d3.layout.histogram!
            ..value ~> it[@property]
            ..bins 40
        if @sqrtAxis
            @histogram.value ~> Math.sqrt it[@property]
        range = @histogram.range!

    prepareBrush: ->
        @brush = d3.svg.brush!
            ..x @x
            ..on \brush @~onBrush
        @brushG = @canvas.append \g
            ..attr \class \brush
            ..call @brush
            ..selectAll \.resize
                ..append \rect
                    ..attr \class \border
                    ..attr \width 1
            ..selectAll \rect
                ..attr \height @height
        @brushExtentLine = @brushG.append \line
            ..attr \class "axisLine"
            ..attr \y1 @height + 2
            ..attr \y2 @height + 2

    drawAxes: ->
        xAxis = d3.svg.axis!
            ..scale @x
            ..tickFormat ~>
                | @sqrtAxis and it > 0 => "#{it ^ 2}%"
                | @property == \vek_prumer => "#it"
                | otherwise => "#it%"
            ..tickSize 4
            ..outerTickSize 0
            ..orient \bottom
        @xAxisGroup = @axesGroup.append \g
            ..attr \class "axis x"
            ..attr \transform "translate(0, #{@height + @padding.0 + 2})"
            ..call xAxis
            ..selectAll \text
                ..attr \dy 8
        if @x.domain!.0 == 0
            @xAxisGroup.select "g.tick:first-child text"
                ..attr \dx 8
        @xAxisTexts = @xAxisGroup.selectAll \.tick
