require 'redcarpet'
require 'sinatra'
require 'erb'

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
	nav = ''
	content = ''
	tmp = '/tmp/' + Random.new_seed.to_s
	system('git clone ' + project + '.wiki.git ' + tmp)

	index = File.read(tmp + '/_Sidebar.md')

	index = index.gsub(/\[\[(.*?)\|(.*?)\]\]/i, '[\1](#\2)')
	index = index.gsub(/\[\[(.*?)\]\]/i) { |m| '[' + $1 + '](#' + $1.gsub(/\s/, '-') + ')' }
	index = index.gsub(/(\[.*?\])\(#{base}\/?(.*?)\)/i, '\1(#\2)')

	index.split("\n").each do |line|
		if /\(#.*?\)/.match(line)
			page = line.gsub(/^.*?\(#(.*)?\)$/, '\1')
			pages.push(page)
		end
	end

	nav = markdown.render(index)
	nav = nav.gsub(/<ol>/, '<ol class="nav navbar-nav nav-pills">');

	pages.each do |page|
		if !File.exist?(tmp + '/' + page + '.md')
			return page + ' does not exist'
		end
		file = File.read(tmp + '/' + page + '.md');

		file = file.gsub(/\[\[(.*?)\|(.*?)\]\]/i, '[\1](#\2)')
		file = file.gsub(/\[\[(.*?)\]\]/i) { |m| '[' + $1 + '](#' + $1.gsub(/\s/, '-') + ')' }
		file = file.gsub(/\s(?=\[^\(\)\]*\]\])/, '-')
		file = file.gsub(/(\[.*?\])\(#{base}\/?(.*?)\)/i, '\1(#\2)')

			content += '<div class="link page-header clearfix" id="' + page + '"></div><section>'
		if page != 'Home'
			content += '<h1>' + page.gsub(/-/, ' ') + '</h1>'
		end
		content += markdown.render(file)
			content += '<hr></section>'
	end

	erb = ERB.new(File.read('template.erb'))
	namespace = OpenStruct.new(
		nav: nav,
		project: project,
		content: content,
		name: name,
		bootswatch: params['bootswatch'] ? params['bootswatch'] : 'flatly',
		highlightjs: params['highlightjs'] ? params['highlightjs'] : 'github'
	)
	return erb.result(namespace.instance_eval { binding })

end

get '/' do
	File.read('index.html')
end

run Sinatra::Application.run!
