# Monis
Monis is a hyper-fast light-weight SSG written in Crystal.

Under my benchmarks (rendering this readme a 100 times), a large site can be generated in less then 25ms!

## Build

To build run `shards build --release`, if it asks you to run `shards update` you have to run with the `--ingore-crystal-version` flag because `front_matter` has not been updated to have crystal 1.0.0 in its `shards.yml`  
The compiled binary will be in `/bin`

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

## File structure for sites
`/content`: Anything here gets rendered  
`/static`: These files just get copied over to `/out/static`  
`/theme`: Currently only `index.html.js` gets used in this, but this is the Jinja2 template for the website.  
`/theme/static`: These are static files for a theme
`/out`: This is the output of the generator once it has been run !!DONT STORE ANYTHING IMPORTANT HERE IT GETS WIPED ON EACH RUN!!  

## Contributing

1. Fork it (<https://github.com/your-github-user/monis/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [l3gacy](https://github.com/your-github-user) - creator and maintainer