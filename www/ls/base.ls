demografie = ig.data.demografie.split "\n"
    .map (line) ->
        [KSCM, CSSD, TOP, KDU, Pirati, ANO, ODS, SZ, Svobodni, Usvit, Ostatni, Nevolici, mimo_byty, verici, vek_prumer, vdani, vzdelani_zakladni, vzdelani_stredni, vzdelani_maturita, vzdelani_vysoka, prac_studenti, nikdy_nezamestnani, studenti, nezamestnani, zamestnani, podnikatele, osvc] = line.split "\t"

        out = {KSCM, CSSD, TOP, KDU, Pirati, ANO, ODS, SZ, Svobodni, Usvit, Ostatni, Nevolici, mimo_byty, verici, vek_prumer, vdani, vzdelani_zakladni, vzdelani_stredni, vzdelani_maturita, vzdelani_vysoka, prac_studenti, nikdy_nezamestnani, studenti, nezamestnani, zamestnani, podnikatele, osvc}
        for key, value of out => out[key] = parseFloat value
        out
demografie.shift!
parties = for abbr in <[KSCM CSSD TOP KDU Pirati ANO ODS SZ Svobodni Usvit Ostatni Nevolici]>
    new ig.Party abbr

container = d3.select ig.containers.base
resultsAreaContainer = container.append \div
    ..attr \class \resultsAreaContainer
resultsArea = new ig.ResultsArea do
    resultsAreaContainer
    parties

parties.0.sum = 20
resultsArea.redraw!
console.log demografie.0
