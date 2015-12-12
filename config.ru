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
	base = project + '/wiki'
	name = repo

	pages = []
	newindex = ''
	content = ''
	tmp = '/tmp/' + Random.new_seed.to_s
	system('git clone ' + project + '.wiki.git ' + tmp)
	#tmp = 'wiki/'

	index = File.read(tmp + '/_Sidebar.md')

	index = index.gsub(/\[\[(.*?)\|(.*?)]\]/i, '[\1](#\2)')
	index = index.gsub(/\[\[(.*?)\]\]/i, '[\1](#\1)')

	# this should repeat and place all spaces...not just one
	index = index.gsub(/\(#(.*) (.*)\)/i, '(#\1-\2)')
	index = index.gsub(/(\[.*?\])\(#{base}\/?(.*?)\)/i, '\1(#\2)')
	index = index.gsub(/\(#\)/, '(#top)')

	index.split("\n").each do |line|
		if /\(#.*?\)/.match(line)
			page = line.gsub(/^.*?\(#(.*)?\)$/, '\1')
			if page == 'top'
				next
			end
			pages.push(page)
		end
	end

	newindex = markdown.render(index)

	pages.each do |page|
		if !File.exist?(tmp + '/' + page + '.md')
			return page + ' does not exist'
		end
		file = File.read(tmp + '/' + page + '.md');
		file = file.gsub(/(\[.*?\])\(#{base}(.*?)\)$/, '\1(#\2)')
		content += '<div class="link" id="' + page + '"></div><section><h1>' + page.gsub(/-/, ' ') + '</h1>'
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
