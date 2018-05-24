#### Main instructions
# build and deploy book
all: build deploy

#### Define variables
ifdef ComSpec
	RM=del /F /Q
	RMDIR=rmdir
	PATHSEP2=\\
	MV=MOVE
else
	RM=rm -f
	RMDIR=rm -rf
	PATHSEP2=/
	MV=mv
endif

#### Individual instructions
# clean compiled book
clean:
	@$(RMDIR) _book
	@$(RMDIR) _bookdown_files

# reset book to orginal text -- warning: this will reset all the book pages
reset: clean
	@$(MV) index.Rmd index.Rmd.bck
	@$(RM) *.Rmd
	@$(MV) index.Rmd.bck index.Rmd

# generate initial book with no text (warning: this will reset all the pages)
init:
	@docker run --name=bba -w /tmp -dt 'brisbanebirdteam/build-env:latest' \
	&& docker cp . bba:/tmp/ \
	&& docker exec bba sh -c "Rscript code/scripts/initialize_book.R TRUE" \
	&& docker cp bba:/tmp/_bookdown.yml . \
	&& docker exec bba sh -c "zip -r rmd.zip *.Rmd" \
	&& docker cp bba:/tmp/rmd.zip . \
	&& unzip -o rmd.zip \
	&& rm rmd.zip || true
	@docker stop -t 1 bba || true && docker rm bba || true

# update graphs in existing book pages with graphs in template file
update: data/* code/initialize_book.R
	@docker run --name=bba -w /tmp -dt 'brisbanebirdteam/build-env:latest' \
	&& docker cp . bba:/tmp/ \
	&& docker exec bba sh -c "Rscript code/scripts/initialize_book.R FALSE" \
	&& docker cp bba:/tmp/_bookdown.yml . \
	&& docker exec bba sh -c "zip -r rmd.zip *.Rmd" \
	&& docker cp bba:/tmp/rmd.zip . \
	&& unzip -o rmd.zip \
	&& rm rmd.zip || true
	@docker stop -t 1 bba || true && docker rm bba || true

# make container
run:
	@docker run --name=bba -dt 'brisbanebirdteam/build-env:latest'

stop:
	@docker stop -t 1 bba || true && docker rm bba || true

# build book
build:


# deploy book to website
deploy:
	echo "TODO"

.PHONY: clean init data update build deploy reset
