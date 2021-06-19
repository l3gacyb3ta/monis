require "./front_matter"
require "crinja"
require "markd"
require "yaml"

# The main monis engine
module Monis
  VERSION = "0.2.0"

  if Dir.exists? "out"
    puts "Cleaning old generation"
    system "rm -rf out"
  end

  # ---------------- Jinja template engine setup ----------------
  env = Crinja.new
  env.loader = Crinja::Loader::FileSystemLoader.new("theme/")

  rawfiles = Dir.glob("content/**/*") # Files that are under content
  files = [] of String                # An empty Array of filenames without directories

  rawfiles.each do |filename|
    if filename.ends_with? ".md"
      files.push filename # Add the file if it of a type we support
    end
  end

  content = "Nothing yet!"
  template = env.get_template("index.html.j2")

  files.each do |filename|
    puts "Generating HTML for " + filename

    FrontMatter.open(filename) { |front_matter, content_io|
      data = YAML.parse front_matter
      permalink = data["permalink"].as_s

      rawmd = content_io.gets_to_end
      content = Markd.to_html(rawmd)

      # This allows for custom configs for themes.
      configdata = {} of String => String

      data.as_h.each do |item|
        configdata[item[0].as_s] = item[1].as_s
        # p! configdata
      end

      # Do something with the front matter and content.
      # Parse the front matter as YAML, JSON or something else?

      # Render the template HTML with our data
      basicconfig = {"content" => content}
      # p! basicconfig.merge(configdata)
      rendered_page = template.render(basicconfig.merge(configdata))


      # write out rendered_page

      # create directories for page
      subs = permalink.split("/")
      count = 0

      subs.each do |dirname|
        if dirname == subs[-1]
        else
          recreateddir = "out" + subs[0..count].join('/')
          if Dir.exists? recreateddir
          else
            system "mkdir " + recreateddir
          end
        end
        count = count + 1
      end

      if Dir.exists? "out"
        File.write("out" + permalink + ".html", rendered_page)
      else
        system "mkdir out"
        File.write("out" + permalink + ".html", rendered_page)
      end
      puts "Generated " + permalink + ".html"
    }
  end

  puts "HTML Generation finished!"

  puts "Tranfering static content"
  if Dir.exists? "static"
    system "mkdir out/static"
    system "cp -r static/* out/static"
  end
  if Dir.exists? "theme/static"
    if Dir.exists? "out/static"
    else
      system "mkdir out/static"
    end

    system "cp -r theme/static/* out/static"
  end
  puts "Static content moved"
end
