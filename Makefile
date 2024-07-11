.PHONY : all
all :
	@ latexmk -pdf -interaction=nonstopmode main.tex

plots/core_bench.%.txt: map-microbenchmarks/data/core_bench.%.txt
	cp $< $@

.PHONY: plots-data
plots-data: plots/core_bench.4.txt plots/core_bench.5.txt

plots/plot.%.svg: map-microbenchmarks/data/plot.%.svg
	cp $< $@

plots/plot.%.pdf: plots/plot.%.svg Makefile
	inkscape -D $< -o $@ --export-latex
	# this creates both a .pdf and a .pdf_tex file
	# remove some unicode characters that pdflatex does not support
	sed -i 's/1×106/$$10^6$$/g' $@_tex
	sed -i 's/5×/5$$\\times$$/g' $@_tex

.PHONY: plots
plots: plots/plot.4.pdf plots/plot.5.pdf

.PHONY : clean
clean :
	@ git clean -fX
