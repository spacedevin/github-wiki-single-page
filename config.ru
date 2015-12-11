#require './run'
#require 'github/markup'
require 'redcarpet'

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, lax_spacing: true, space_after_headers: true, with_toc_data: true)


#file = "tipsy.wiki/About.md"
#print GitHub::Markup.render(file, File.read(file))

project = 'https://github.com/tipsyphp/tipsy'
base = project + '/wiki/'
name = 'tipsy'

path = 'wiki/'
index = File.read(path + '_Sidebar.md').split("\n")
pages = []
newindex = ''
content = ''

index.each do |line|
	if /\(#{base}.*\)/.match(line)
		pages.push(line.gsub(/^.*?\(#{base}(.*)?\)$/, '\1'))
		newindex += line.gsub(/^(.*?)\(#{base}(.*?)\)$/, '\1(#\2)') + "\n"
	elsif /nasd/.match(line)
		print "no"
	end
	#puts line
end

#newindex = GitHub::Markup.render(path + '_Sidebar.md', newindex)
newindex = markdown.render(newindex)

pages.each do |page|
	file = File.read(path + page + '.md');
	file = file.gsub(/(\[.*?\])\(#{base}(.*?)\)$/, '\1(#\2)')
	content += '<section><a name="' + page + '"></a><h1>' + page.gsub(/-/, ' ') + '</h1>'
	#content += GitHub::Markup.render(path + page + '.md', file) + "\n"
	content += markdown.render(file)
	content += '</section><hr>'

	#print content
end

template = File.read('template.html')
template = template.gsub(/<name><\/name>/, name + ' docs');
template = template.gsub(/<project><\/project>/, project);
template = template.gsub(/<nav><\/nav>/, '<nav>' + newindex + '</nav>');
template = template.gsub(/<div class="wiki"><\/div>/, '<div class="wiki">' + content + '</div>');

run lambda { |env| [200, {'Content-Type'=>'text/html'}, StringIO.new(template)] }
