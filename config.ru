#require './run'
require 'github/markup'

#file = "tipsy.wiki/About.md"
#print GitHub::Markup.render(file, File.read(file))

base = 'https://github.com/tipsyphp/tipsy/wiki/'
index = File.read('wiki/_Sidebar.md').split("\n")
pages = []
newindex = ''
#pages ||= Array.new
index.each do |line|
	if /\(#{base}.*\)/.match(line)
		pages.push(line.gsub(/^.*?\(#{base}(.*)?\)$/, '\1'))
		newindex += line.gsub(/^(.*?)\(#{base}(.*?)\)$/, '\1(#\2)') + "\n"
	elsif /nasd/.match(line)
		print "no"
	end
	#puts line
end

print newindex

#out = GitHub::Markup.render(file, File.read(file))
#run lambda { |env| [200, {'Content-Type'=>'text/plain'}, StringIO.new(out)] }
