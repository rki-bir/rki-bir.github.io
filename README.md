# RKI Bioinformatics Research

Content of the RKI-BIR web page. 

Some contents of this README were shamelessly stolen from the [case-group](https://github.com/CaSe-group/case-group.github.io/). Thx [@replikation](https://github.com/replikation).

[hackmd.io notes](https://hackmd.io/@GqOnlbqgSdKAMwgCUU_ljQ/BJmM49Q4F) about how this github page was initially setup w/ Materials for MkDocs and the autobuild. 

## Change content

Go to the coresponding `.md` file and edit it and commit: done. The page will re-build via a GitHub Action. 

## Adding a new page or changing the structure

mkdocs needs a `.md` file in `docs/` and the correct "link" in `mkdocs.yml`

Example: we want to add `foo.md` to the "bar" kategory on the webpage

1) create the md file
   * `touch docs/bar/foo.md` 
   * edit `foo.md` using markdown syntax
2) "link" the `foo.md`
   * `code mkdocs.yml` 
   * go to `# Navigation`
      * this represents the "categories" written as plain text
      * you should understand this based on the given structure ;)
   * add this:

```yml
- whateveryouwant: 
        - whateveryouwant2: bar/foo.md
```

## Change webpage appearance and style

* Detailed style tutorial can be found [here](https://squidfunk.github.io/mkdocs-material/)
* a docker will render the local webpage so you can check what is happening
* to do a "dry run and live test" run the following commands:

```bash
git clone https://github.com/rki-bir/rki-bir.github.io.git
# or if repo exists
git pull

# within the directory of the git do
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material

# or install mkdocs via pip and run it
pip install mkdocs-material
mkdocs serve & 
```

* open the local webpage in your browser via `http://0.0.0.0:8000/` (for Docker) or the URL printer on the terminal
   * or click [this link](http://0.0.0.0:8000/)
* now you can check the changes

## Format images

Images can be best inserted via markdown syntax. But you can also use HTML code. The width and position can be changed via markdown style syntax. The custom `stylesheets/extra.css` adds classes for `#shadow` and `#round` corners that can be activated via:

```markdown
![](/team/martin.png#shadow#round){style="width:120px" align="right"}
```
