require "front_matter"
require "crinja"
require "markd"
require "yaml"

# ---------------- Jinja template engine setup ----------------
env = Crinja.new
env.loader = Crinja::Loader::FileSystemLoader.new("theme/")

path = Dir.new "content"
files = [] of String

# Content descovery
path.each do |itered|
  if [".", ".."].includes? itered
  else
    puts "Found " + itered
    files.push "content/" + itered
  end
end

content = "Nothing yet!"
template = env.get_template("index.html.j2")

files.each do |filename|
  puts "Generating HTML for " + filename

  FrontMatter.open(filename) { |front_matter, content_io|
    data = YAML.parse front_matter
    title = data["title"].as_s

    rawmd = content_io.gets_to_end
    content = Markd.to_html(rawmd)

    # Do something with the front matter and content.
    # Parse the front matter as YAML, JSON or something else?

    # Render the template HTML with our data
    rendered_page = template.render({"content" => content, "title" => title})
    # write out rendered_page

    outputname = filename.split("/")[1].split(".")[0] + ".html"

    File.write("out/" + outputname, rendered_page)

    puts "Generated " + outputname
  }
  
end

puts "HTML Generation finished!"
