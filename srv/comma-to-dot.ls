require! {
    fs
}
fs.readFileSync "#__dirname/../data/volby_demo_abs_trimmed.csv" .toString!replace /,/g "." |> fs.writeFileSync "#__dirname/../data/volby_demo_abs_trimmed_dot.csv", _
