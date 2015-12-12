require 'redcarpet'
require 'sinatra'
require 'erb'
require 'fileutils'


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

	def self.create(owner, repo, params)
		markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, lax_spacing: true, space_after_headers: true, with_toc_data: true)

		project = 'https://github.com/' + owner + '/' + repo
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

		if !File.exist?(tmp + '/_Sidebar.md')
			return Wiki.index('No custom sidebar')
		end

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
			bootswatch: params['bootswatch'] ? params['bootswatch'] : (ENV['WIKI_BOOTSWATCH'] ? ENV['WIKI_BOOTSWATCH'] : 'flatly'),
			highlightjs: params['highlightjs'] ? params['highlightjs'] : (ENV['WIKI_BOOTSWATCH'] ? ENV['WIKI_BOOTSWATCH'] : 'github')
		)

		if !cache
			FileUtils.rm_rf(tmp)
		end

		return erb.result(namespace.instance_eval { binding })
	end
end


get '/:owner/:repo' do
	if ENV['WIKI_REPO']
		repo = ENV['WIKI_REPO'].split('/')
		Wiki.create(repo[0], repo[1], params)
	else
		Wiki.create(params['owner'], params['repo'], params)
	end
end


get '/' do
	if ENV['WIKI_REPO']
		repo = ENV['WIKI_REPO'].split('/')
		Wiki.create(repo[0], repo[1], params)
	else
		Wiki.index('')
	end
end


run Sinatra::Application.run!
