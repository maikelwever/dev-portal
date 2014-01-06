# This is the makefile for the Paylogic developer portal. It's based on the
# makefile generated by the command `pelican-quickstart' installed by Pelican,
# a static site generator written in Python. Everything we don't need has been
# removed, to keep things as simple as possible (e.g. support for publishing
# with FTP, SSH, rsync, Dropbox and S3).

PY=python
PELICAN=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

help:
	@echo 'Makefile for the Paylogic developer portal'
	@echo ''
	@echo '  Usage:'
	@echo ''
	@echo '    make html          (re)generate the web site'
	@echo '    make clean         remove the generated files'
	@echo '    make regenerate    regenerate files upon modification'
	@echo '    make publish       generate using production settings'
	@echo '    make serve         serve site at http://localhost:8000'
	@echo '    make devserver     start/restart develop_server.sh'
	@echo '    make stopserver    stop local server'
	@echo '    make github        upload the web site via gh-pages'
	@echo ''

html: clean $(OUTPUTDIR)/index.html

$(OUTPUTDIR)/%.html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	[ ! -d $(OUTPUTDIR) ] || find $(OUTPUTDIR) -mindepth 1 -delete

regenerate: clean
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
	cd $(OUTPUTDIR) && $(PY) -m pelican.server

devserver:
	$(BASEDIR)/develop_server.sh restart

stopserver:
	kill -9 `cat pelican.pid`
	kill -9 `cat srv.pid`
	@echo 'Stopped Pelican and SimpleHTTPServer processes running in background.'

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

github: publish
	# GitHub pages requires /404.html at the root of the directory structure and
	# for some reason adding a /404.rst document confuses Pelican. So instead we
	# put the 404 page in the /pages/ directory as a hidden page, and copy the
	# generated HTML to /404.html so that the error page actually works :-).
	cp $(OUTPUTDIR)/pages/page-not-found.html $(OUTPUTDIR)/404.html
	# To use a custom DNS name with GitHub Pages there needs to be a /CNAME file
	# in the 'gh-pages' branch containing the DNS name to be used for the site.
	echo developer.paylogic.com > $(OUTPUTDIR)/CNAME
	# Import the generated static files to the 'gh-pages' branch.
	ghp-import $(OUTPUTDIR)
	# Publish the updated site to GitHub.
	git push origin master gh-pages

.PHONY: html help clean regenerate serve devserver publish github