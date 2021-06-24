require "./front_matter"
require "option_parser"
require "file_utils"
require "crinja"
require "markd"
require "yaml"

# The main monis engine
module Monis
  VERSION = "0.4.0"

  if Dir.exists? "out"
    puts "Cleaning old generation"
    FileUtils.rm_rf "./out"
  end

  # if this flag is true, then create the directory structure, as well as a basic theme file.
  _init = false

  # # File structure for sites
  # `/content`: Anything here gets rendered
  # `/static`: These files just get copied over to `/out/static`
  # `/theme`: Currently only `index.html.js` gets used in this, but this is the Jinja2 template for the website.
  # `/theme/static`: These are static files for a theme
  # `/out`: This is the output of the generator once it has been run !!DONT STORE ANYTHING IMPORTANT HERE IT GETS WIPED ON EACH RUN!!

  OptionParser.parse do |parser|
    parser.banner = "Monis CLI"
    parser.on "init", "create the basic folder structure." do
      _init = true
    end
  end

  if _init
    FileUtils.mkdir ["content", "theme", "theme/static", "static"]
    File.write "theme/index.html.j2", "{{content}}"
    # quit the program
    exit
  end

  # ---------------- Jinja template engine setup ----------------
  env = Crinja.new
  env.loader = Crinja::Loader::FileSystemLoader.new("theme/")

  rawfiles = Dir.glob "content/**/*" # Files that are under content
  files = [] of String                # An empty Array of filenames without directories

  rawfiles.each do |filename|
    if filename.ends_with? ".md"
      files.push filename # Add the file if it of a type we support
    end
  end

  if File.exists? "config.yml"
    # Read config yaml from the `config.yml` file
    configfiledata = {} of String => String
    data = YAML.parse File.new("config.yml").gets_to_end

    data.as_h.each do |item|
      configfiledata[item[0].as_s] = item[1].as_s
    end
  else
    STDERR.puts "No config.yml detected in the current directory!"
    exit 1
  end

  content = "Nothing yet!"
  template = env.get_template "index.html.j2"

  files.each do |filename|
    puts "Generating HTML for " + filename

    FrontMatter.open(filename) { |front_matter, content_io|
      data = YAML.parse front_matter
      permalink = data["permalink"].as_s

      rawmd = content_io.gets_to_end
      content = Markd.to_html rawmd

      # This allows for custom configs for themes.
      frontdata = {} of String => String

      data.as_h.each do |item|
        frontdata[item[0].as_s] = item[1].as_s
        # p! configdata
      end

      # Do something with the front matter and content.
      # Parse the front matter as YAML, JSON or something else?

      # Render the template HTML with our data
      basicconfig = {"content" => content, "config" => configfiledata}
      # p! basicconfig.merge(configdata)
      rendered_page = template.render(basicconfig.merge(frontdata))

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
            FileUtils.mkdir recreateddir
          end
        end
        count = count + 1
      end

      if Dir.exists? "out"
        File.write "out" + permalink + ".html", rendered_page
      else
        FileUtils.mkdir "out"
        File.write "out" + permalink + ".html", rendered_page
      end
      puts "Generated " + permalink + ".html"
    }
  end

  puts "HTML Generation finished!"

  puts "Tranfering static content"
  if Dir.exists? "static"
    FileUtils.mkdir "out/static"
    FileUtils.cp_r "static", "out/static"
  end
  if Dir.exists? "theme/static"
    if Dir.exists? "out/static"
    else
      FileUtils.mkdir "out/static"
    end

    FileUtils.cp_r "theme/static", "out/static"
  end
  puts "Static content moved"
end
