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

ig.Filter = class Filter
    height: 100
    width: 430
    padding: [35 4 20 1]
    (@data, @property, parentElement) ->
        @element = parentElement.append \svg
            ..attr \class \filter
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
        bins = @histogram @data
        @computeScales bins
        @drawData @fullDataGroup, bins
        @currentDataBars = @drawData @currentDataGroup, bins
        @prepareBrush!
        @drawAxes!
        @element.append \text
            ..attr \class \heading
            ..html propertyNames[@property]
            ..attr \y 16

    onBrush: ->
        extent = @brush.extent!
        @brushExtentLine
            ..attr \x1 @x extent.0
            ..attr \x2 @x extent.1
        @xAxisTexts.classed \active ~> extent.0 < it < extent.1
        if @sqrtAxis
            extent .= map -> it^2
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
            ..attr \height ~> @y it.y
            ..attr \width -2 + @x bins.1.x
            ..attr \y ~> @height - @y it.y


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
        if @property == \verici
            @brush.extent [30 80]
        brushG = @canvas.append \g
            ..attr \class \brush
            ..call @brush
            ..selectAll \.resize
                ..append \rect
                    ..attr \class \border
                    ..attr \width 1
            ..selectAll \rect
                ..attr \height @height
        @brushExtentLine = brushG.append \line
            ..attr \class "axisLine"
            ..attr \y1 @height + 2
            ..attr \y2 @height + 2
        if @property == \verici
            <~ setTimeout _, 10
            @brush.event brushG

    drawAxes: ->
        xAxis = d3.svg.axis!
            ..scale @x
            ..tickFormat ~>
                | @sqrtAxis and it > 0 => "#{(Math.sqrt it).toFixed 1}%"
                | @property == \vek_prumer => "#it"
                | otherwise => "#it%"
            ..tickSize 4
            ..outerTickSize 0
            ..orient \bottom
        @xAxisGroup = @axesGroup.append \g
            ..attr \class "axis x"
            ..attr \transform "translate(0, #{@height + @padding.0 + 2})"
            ..call xAxis
            ..select "g.tick:first-child text"
                ..attr \dx 8
            ..selectAll \text
                ..attr \dy 8
        @xAxisTexts = @xAxisGroup.selectAll \.tick
