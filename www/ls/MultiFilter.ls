ig.MultiFilter = class MultiFilter
    (@fullData) ->
        @filters = []
        @filters_assoc = {}
        @currentData = @fullData

    onFilterChange: (property, extent) ->
        if extent isnt null
            @setFilter ...
        else
            @clearFilter property

    recompute: ->
        @currentData = @fullData.filter ~>
            for {property, extent} in @filters
                if not (extent.0 <= it[property] <= extent.1)
                    it.valid = false
                    return false
            it.valid = true
            return true
        @onRecomputed @currentData

    setFilter: (property, extent) ->
        if @filters_assoc[property]
            that.extent = extent
        else
            @filters_assoc[property] = filter = {property, extent}
            @filters.push filter
        @recompute!

    clearFilter: (property) ->
        filter = @filters_assoc[property]
        delete @filters_assoc[property]
        @filters.splice do
            @filters.indexOf filter
            1
        @recompute!
