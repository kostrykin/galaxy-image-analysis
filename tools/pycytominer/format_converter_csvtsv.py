import argparse
import csv

DELIMS = {"csv": ",", "tsv": "\t"}

p = argparse.ArgumentParser(description="Convert between CSV and TSV.")
p.add_argument("-i", "--input", required=True, nargs="+", help="input file(s)")
p.add_argument("-o", "--output", required=True, nargs="+", help="output file(s)")
p.add_argument("-c", "--convert", choices=["csv2tsv", "tsv2csv"], required=True, help="conversion direction")
args = p.parse_args()

if len(args.input) != len(args.output):
    p.error(f"number of inputs ({len(args.input)}) must match number of outputs ({len(args.output)})")

src, dst = ("csv", "tsv") if args.convert == "csv2tsv" else ("tsv", "csv")

for infile, outfile in zip(args.input, args.output):
    with open(infile, newline="") as fin, open(outfile, "w", newline="") as fout:
        writer = csv.writer(fout, delimiter=DELIMS[dst])
        for row in csv.reader(fin, delimiter=DELIMS[src]):
            writer.writerow(row)
