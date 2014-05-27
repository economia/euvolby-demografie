lines = ig.data.demografie.split "\n"
    ..pop! # header
    ..shift! # newline on EOF

demografie = lines.map (line) ->
        [KSCM, CSSD, TOP, KDU, Pirati, ANO, ODS, SZ, Svobodni, Usvit, Ostatni, Nevolici, mimo_byty, verici, vek_prumer, vdani, vzdelani_zakladni, vzdelani_stredni, vzdelani_maturita, vzdelani_vysoka, prac_studenti, nikdy_nezamestnani, studenti, nezamestnani, zamestnani, podnikatele, osvc] = line.split "\t"
        out = {KSCM, CSSD, TOP, KDU, Pirati, ANO, ODS, SZ, Svobodni, Usvit, Ostatni, Nevolici, mimo_byty, verici, vek_prumer, vdani, vzdelani_zakladni, vzdelani_stredni, vzdelani_maturita, vzdelani_vysoka, prac_studenti, nikdy_nezamestnani, studenti, nezamestnani, zamestnani, podnikatele, osvc}
        for key, value of out => out[key] = parseFloat value
        if not out.Nevolici => out.Nevolici = 0
        out

partyAbbrs = <[KSCM CSSD TOP KDU Pirati ANO ODS SZ Svobodni Usvit Ostatni Nevolici]>
parties = for abbr in partyAbbrs
    new ig.Party abbr

container = d3.select ig.containers.base
resultsAreaContainer = container.append \div
    ..attr \class \resultsAreaContainer
resultsArea = new ig.ResultsArea do
    resultsAreaContainer
    parties

for line in demografie
    for abbr, index in partyAbbrs
        parties[index].sum += line[abbr]

# parties.0.sum = 20
resultsArea.redraw!
filters = for property in <[verici]>
    new ig.Filter demografie, property, container
console.log demografie.pop!
