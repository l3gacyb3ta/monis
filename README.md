# Monis
Monis is a hyper-fast light-weight SSG written in Crystal.
## File structure
`/content`: Anything here gets rendered  
`/static`: These files just get copied over to `/out/static`  
`/theme`: Currently only `index.html.js` gets used in this, but this is the Jinja2 template for the website.  
`/out`: This is the output of the generator once it has been run !!DONT STORE ANYTHING IMPORTANT HERE IT GETS WIPED ON EACH RUN!!  
## File formating
Template:
```
---
title: "Home page"
permalink: "/index"
---
# Welcome to my website
Hello and welcome!
```
The frontmatter contains the permalink and the title, and the page content is after the frontmatter