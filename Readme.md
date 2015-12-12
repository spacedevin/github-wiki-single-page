## Github Wiki Single Page
A single page wiki generator using redcarpet and bootstrap.


### Themes
- **[Bootstrap](http://getbootstrap.com/)**: Visit [BootstrapCDN](https://www.bootstrapcdn.com/bootswatch/) to see the included themes.
- **[Highlight JS](https://highlightjs.org/)**: Visit [highlightjs.org/static/demo](https://highlightjs.org/static/demo/) to see the included themes.


### Set up your wiki
1. Create wiki pages using GitHub's wiki system
1. Create a custom sidebar and link to all pages you want included in the wiki
  *Note: it will not include any pages that are not in the sidebar links*

### Deploying your own version

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

##### Environment Variables

- **WIKI_CACHE**: Cache git the wiki in a tmp dir. Note that this only caches the repo, not the html
- **WIKI_REPO**: A repo to specificy (owner/repo). When specified all requests will
- **WIKI_BOOTSWATCH**: The default bootswatch theme
- **WIKI_HIGHLIGHTJS**: The default highlightjs theme


### Running
Just open your browser to the url where you installed this and follow the instructions.
