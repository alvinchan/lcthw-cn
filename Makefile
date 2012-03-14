JUNK_FILES=$(FINAL).* *.aux *.log styles/*.aux
SOURCE=book
WEBSITE=learncodethehardway.org:/var/www/learncodethehardway.org/c/
FINAL=learn-c-the-hard-way

book:
	dexy
	cp Makefile output/
	${MAKE} -C output clean $(FINAL).pdf
	rm -rf output/*.dvi output/*.pdf
	${MAKE} -C output $(FINAL).pdf

draft: $(FINAL).dvi

$(FINAL).pdf:
	cp $(SOURCE).tex $(FINAL).tex
	pdflatex -halt-on-error $(FINAL).tex

html: 
	cd output && cp $(SOURCE)-html.tex $(FINAL).tex
	cd output && htlatex $(FINAL).tex "book,index=1,2,next,fn-in"
	gsed -i -f clean.sed output/*.html
	
view: $(FINAL).pdf
	evince $(FINAL).pdf

clean:
	rm -rf $(JUNK_FILES)
	find . -name "*.aux" -exec rm {} \;
	rm -rf output

release: clean $(FINAL).pdf draft $(FINAL).pdf sync

syncpdf: book
	rsync -vz output/$(FINAL).pdf $(WEBSITE)/$(FINAL).pdf

sync: syncpdf html
	rsync -vz output/$(FINAL).html $(WEBSITE)/book/index.html
	rsync -vz output/*.html output/*.css $(WEBSITE)/book/

