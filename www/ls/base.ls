if \undefined != typeof $
    <~ $
    $ '#col12d-article #detail #text, #perex, H1, .discussion-content .row .r' .unbind!

lines = ig.data.demografie.split "\n"
    ..pop! # header
    ..shift! # newline on EOF

demografie = lines.map (line) ->
        [KSCM, CSSD, TOP, KDU, Pirati, ANO, ODS, SZ, Svobodni, Usvit, Ostatni, Nevolici, mimo_byty, verici, vek_prumer, vdani, vzdelani_zakladni, vzdelani_stredni, vzdelani_maturita, vzdelani_vysoka, prac_studenti, nikdy_nezamestnani, studenti, nezamestnani, zamestnani, podnikatele, osvc] = line.split "\t"
        out = {KSCM, CSSD, TOP, KDU, Pirati, ANO, ODS, SZ, Svobodni, Usvit, Ostatni, Nevolici, mimo_byty, verici, vek_prumer, vdani, vzdelani_zakladni, vzdelani_stredni, vzdelani_maturita, vzdelani_vysoka, prac_studenti, nikdy_nezamestnani, studenti, nezamestnani, zamestnani, podnikatele, osvc}
        for key, value of out => out[key] = parseFloat value
        if not out.Nevolici => out.Nevolici = 0
        volici = out.KSCM + out.CSSD + out.TOP + out.KDU + out.Pirati + out.ANO + out.ODS + out.SZ + out.Svobodni + out.Usvit + out.Ostatni
        out.ucastPrc = volici / (volici + out.Nevolici) * 100
        out.velikostObce = volici + out.Nevolici
        if not out.velikostObce
            out.velikostObce = 1
        out.valid = yes
        out

partyAbbrs = <[KSCM CSSD TOP KDU Pirati ANO ODS SZ Svobodni Usvit Ostatni Nevolici]>
parties = for abbr in partyAbbrs
    new ig.Party abbr

container = d3.select ig.containers.base

recountPartySums = (lines) ->
    for party in parties => party.sum = 0
    for line in lines
        for abbr, index in partyAbbrs
            parties[index].sum += line[abbr]

recountPartySums demografie
resultsArea = new ig.ResultsArea do
    container
    parties

resultsArea.redraw!

filterConnector = (newData) ->
    newDataLength = newData.length
    for filter in filters => filter.setCurrentData newData, newDataLength
    recountPartySums newData
    resultsArea.redraw!
multiFilter = new ig.MultiFilter demografie
    ..onRecomputed = filterConnector
filterContainer = container.append \div
    ..attr \class \filterContainer
filters = for property, index in <[velikostObce vek_prumer vdani vzdelani_zakladni vzdelani_stredni vzdelani_maturita vzdelani_vysoka verici ucastPrc nezamestnani nikdy_nezamestnani mimo_byty prac_studenti studenti zamestnani podnikatele osvc]>
    new ig.Filter demografie, property, filterContainer
        ..onChange = multiFilter~onFilterChange

{top: containerOffset} = ig.utils.offset ig.containers.base

document.addEventListener \scroll ->
    resultsArea.element.classed do
        \fixed
        window.pageYOffset > containerOffset and window.pageYOffset < containerOffset + ig.containers.base.offsetHeight - 230

resultsArea.disableButton.on \click ->
    for filter in filters => filter.cancelBrush!


container.append \a
    ..attr \class \dumbOff
    ..text "Zobrazit pokročilou verzi – další demografické ukazatele a mediány jednotlivých hodnot"
    ..attr \href \#
    ..on \click ->
        d3.event.preventDefault!
        container.classed \dumbed no
container.classed \dumbed yes
