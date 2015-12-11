require 'redcarpet'
require 'sinatra'

configure {
	set :server, :puma
}

get '/:owner/:repo' do

	owner = params['owner']
	repo = params['repo']

	markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, lax_spacing: true, space_after_headers: true, with_toc_data: true)

	project = 'https://github.com/' + owner + '/' + repo
	base = project + '/wiki/'
	name = repo

	pages = []
	newindex = ''
	content = ''
	tmp = '/tmp/' + Random.new_seed.to_s
	system('git clone ' + project + '.wiki.git ' + tmp)

	index = File.read(tmp + '/_Sidebar.md').split("\n")


	index.each do |line|
		if /\(#{base}.*\)/.match(line)
			pages.push(line.gsub(/^.*?\(#{base}(.*)?\)$/, '\1'))
			newindex += line.gsub(/^(.*?)\(#{base}(.*?)\)$/, '\1(#\2)') + "\n"
		elsif /nasd/.match(line)
			print "no"
		end
	end

	newindex = markdown.render(newindex)

	pages.each do |page|
		file = File.read(tmp + '/' + page + '.md');
		file = file.gsub(/(\[.*?\])\(#{base}(.*?)\)$/, '\1(#\2)')
		content += '<section id="' + page + '"><h1>' + page.gsub(/-/, ' ') + '</h1>'
		content += markdown.render(file)
		content += '</section><hr>'

	end

	template = File.read('template.html')
	template = template.gsub(/<name><\/name>/, name + ' docs');
	template = template.gsub(/<project><\/project>/, project);
	template = template.gsub(/<nav><\/nav>/, '<nav class="nav">' + newindex + '</nav>');
	template = template.gsub(/<div class="wiki"><\/div>/, '<div class="wiki">' + content + '</div>');
	return template
	#run lambda { |env| [200, {'Content-Type'=>'text/html'}, StringIO.new(template)] }

end

get '/' do
	File.read('index.html')
end

run Sinatra::Application.run!
