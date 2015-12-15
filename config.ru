require 'redcarpet'
require 'sinatra'
require 'erb'
require 'fileutils'
require 'uri'


class Wiki
	def self.index(error)
		erb = ERB.new(File.read('index.erb'))
		namespace = OpenStruct.new(
			error: error,
			bootswatch: ENV['WIKI_BOOTSWATCH'] ? ENV['WIKI_BOOTSWATCH'] : 'Flatly',
			highlightjs: ENV['WIKI_HIGHLIGHTJS'] ? ENV['WIKI_HIGHLIGHTJS'] : 'github'
		)
		return erb.result(namespace.instance_eval { binding })
	end

	def self.create(owner, repo, url, params)
		markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, lax_spacing: true, space_after_headers: true, with_toc_data: true)

		if url
			project = url
			url = URI(url)
			u = url.path.split('/')
			owner = u[1]
			repo = u[2]
		else
			project = 'https://github.com/' + owner + '/' + repo
		end

		base = project + '/wiki'
		name = repo

		cache = ENV['WIKI_CACHE']

		pages = []
		nav = ''
		content = ''

		tmp = '/tmp/' + (cache ? owner + '-' + repo : Random.new_seed.to_s)
		if cache and params['refresh']
			FileUtils.rm_rf(tmp)
		end

		system('git clone ' + project + '.wiki.git ' + tmp)

		if !File.exist?(tmp + '/.git')
			return Wiki.index('Invalid repository')
		end

		msg = ''

		if File.exist?(tmp + '/_Sidebar.md')
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
		else
			index = ''
			Dir.glob(tmp + '/*.md') do |item|
				item = item.sub('.md', '').sub(tmp + '/', '')
				pages.push(item)
				index += '1. [' + item.gsub(/-/, ' ') + '](#' + item.gsub(/\s/, '-') + ")\n"
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

			content += '<div class="link page-header" id="' + page + '"></div><section class="clearfix">'
			if page != 'Home'
				content += '<h1>' + page.gsub(/-/, ' ') + '</h1>'
			end
			content += markdown.render(file)
			content += '</section><hr>'
		end

		erb = ERB.new(File.read('template.erb'))
		namespace = OpenStruct.new(
			nav: nav,
			project: project,
			content: content,
			name: name,
			bootswatch: params['bootswatch'] ? params['bootswatch'] : (ENV['WIKI_BOOTSWATCH'] ? ENV['WIKI_BOOTSWATCH'] : 'flatly'),
			highlightjs: params['highlightjs'] ? params['highlightjs'] : (ENV['WIKI_BOOTSWATCH'] ? ENV['WIKI_BOOTSWATCH'] : 'github')
		)

		if !cache
			FileUtils.rm_rf(tmp)
		end

		return erb.result(namespace.instance_eval { binding })
	end
end


get '/:owner/:name' do
	url = params['repo']
	if ENV['WIKI_REPO']
		url = ENV['WIKI_REPO']
		Wiki.create('', '', url, params)
	else
		Wiki.create(params['owner'], params['name'], url, params)
	end
end


get '/' do
	if ENV['WIKI_REPO']
		url = ENV['WIKI_REPO']
		Wiki.create('', '', url, params)
	else
		Wiki.index('')
	end
end


run Sinatra::Application.run!
