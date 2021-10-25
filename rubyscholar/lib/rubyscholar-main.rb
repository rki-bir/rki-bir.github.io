require 'nokogiri'
require 'open-uri'
require 'rubyscholar-version'
require 'active_support/inflector'
require 'json'

class String
  def clean
    # removes leading and trailing whitespace, commas
    self.gsub!(/(^[\s,]+)|([\s,]+$)/, '')
    return self
  end
end

module Rubyscholar
  class Paper < Struct.new(:scholar, :crossref)
  end

  class Parser
    attr_accessor :parsedPapers, :crossRefEmail

    def initialize(url, crossRefEmail = "")
      @parsedPapers  = []
      @crossRefEmail = crossRefEmail # if nil doesn't return any crossRef Info (or DOI)
      parse(url)
    end

    def parse(url)
      STDERR << "Will check #{url}.\n"
      page_content = URI.open(url,
                          'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2')
      page = Nokogiri::HTML(page_content, nil, 'utf-8')
      papers = page.css(".gsc_a_tr")
      STDERR << "Found #{papers.length} papers.\n"
      papers.each do |paper|
        scholar = {}
        scholar[:title] = paper.css(".gsc_a_at").text rescue ''
        scholar[:title].gsub!(/\.$/, '')

        scholar[:googleUrl] = paper.children[0].children[0].attribute('href').text rescue ''
        scholar[:authors]   = paper.children[0].children[1].text.clean rescue ''
        scholar[:authors].gsub!("...", "et al")

        scholar[:journal]        = paper.children[0].children[2].text rescue ''
        scholar[:journalName]    = scholar[:journal].split(/,|\d/).first.clean  rescue ''
        scholar[:journalDetails] = scholar[:journal].gsub(scholar[:journalName], '').clean
        scholar[:year]           = scholar[:journalDetails].match(/, \d+$/)[0].sub('()','')  rescue ''
        scholar[:journalDetails] = scholar[:journalDetails].gsub(scholar[:year], '').clean
        scholar[:year]           = scholar[:year].sub('()','').clean

        #citations
        citeInfo                = paper.css('.gsc_a_ac')
        scholar[:citationCount] = citeInfo.text
        scholar[:citationUrl]   = scholar[:citationCount].empty?  ? nil : citeInfo.attribute('href').to_s

        # get CrossRef Info: needs last name of first author, no funny chars
        crossref = get_crossref(scholar[:authors], scholar[:title], @crossRefEmail)

        @parsedPapers.push(Paper.new(scholar, crossref))
      end
      STDERR << "Scraped #{parsedPapers.length} from Google Scholar.\n"
    end

    # Also get (more detailed) info from crossref (its free)
    # Set your CrossRefEmail int the config
    def get_crossref(authors, title, crossRefEmail)
      return '' if @crossRefEmail.nil?
      lastNameFirstAuthor = ((authors.split(',').first ).split(' ').last )
                              .parameterize.gsub(/[^A-Za-z\-]/, '')
      sleep(1) # to reduce risk
      STDERR << "Getting DOI for paper by #{lastNameFirstAuthor}: #{title}.\n"
      p = URI::Parser.new
      url = 'http://www.crossref.org/openurl?redirect=false' +
        '&pid='    + crossRefEmail +
        '&aulast=' + lastNameFirstAuthor +
        '&atitle=' + p.escape(title) +
        '&format=json'
      JSON.load(URI.open(url)) rescue ''
    end
  end

  class Formatter
    attr_accessor :parser, :nameToHighlight, :pdfLinks, :altmetricDOIs

    def initialize(parser, nameToHighlight = nil, pdfLinks = {}, altmetricDOIs = [], minCitationCount = 1)
      @parser          = parser
      @nameToHighlight = nameToHighlight
      @pdfLinks        = pdfLinks
      @altmetricDOIs   = altmetricDOIs
      @minCitations    = minCitationCount
    end

    def to_json
      papers = {}
      @parser.parsedPapers.each_with_index do |paper, idx|
        index = @parser.parsedPapers.length - idx
        papers[index] = paper.to_h
      end
      papers.to_json
    end

    def to_md
      out_md = ''
      @parser.parsedPapers.each_with_index do |paperData, index|
        paper_entry = ''
        paper = paperData[:scholar]
        doi   = paperData[:crossref]['created']['DOI'] rescue ''
        paper_counter = (@parser.parsedPapers.length - index).to_s
        paper_entry = "#{paper_counter}" + '\. '
        paper_entry += "__#{paper[:title]}__. "
        paper_entry += "_#{paper[:journalName]}_"
        paper_entry += ' (' + paper[:year] + ')</br>' 
        if paper[:authors].include?(@nameToHighlight)
          paper_entry += paper[:authors].sub(Regexp.new(@nameToHighlight + '.*'), '')
          paper_entry += "__#{@nameToHighlight}__"
          paper_entry += paper[:authors].sub(Regexp.new('.*' + @nameToHighlight), '')
        else
          paper_entry += paper[:authors]
        end
        paper_entry += "\n"
        #paper_entry += paper[:journalDetails]

        scholar_icon = ':octicons-book-16:'
        unless doi.empty?
          paper_entry += ' '
          paper_entry += "[#{scholar_icon}](http://dx.doi.org/#{doi})"
        end

        if @pdfLinks.keys.include?(paper[:title])
          paper_entry += ' '
          paper_entry += "[[PDF]](#{@pdfLinks[paper[:title]]})"
        end

        citation_icon = ':octicons-person-16:'
        if paper[:citationCount].to_i > @minCitations
          paper_entry += ' '
          paper_entry += "[#{citation_icon} #{paper[:citationCount]} cites](#{paper[:citingPapers]})"
        end

        if altmetricDOIs.include?(doi)
          paper_entry += ' '
          paper_entry += "#{doi}"
        end

        paper_entry += "\n"
        out_md += paper_entry + "\n" 
      end
      return out_md
    end

    def to_html
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.div(class: "publication") do
          doc.ol do
            @parser.parsedPapers.each_with_index do |paperData, index|
              paper = paperData[:scholar]
              doi   = paperData[:crossref]['created']['DOI'] rescue ''
              doc.li(value: (@parser.parsedPapers.length - index).to_s) do
                doc.b paper[:title]
                doc.text ' (' + paper[:year] + ') '
                if paper[:authors].include?(@nameToHighlight)
                  doc.text( paper[:authors].sub(Regexp.new(@nameToHighlight + '.*'), '') )
                  doc.span(class: "label") { doc.text @nameToHighlight }
                  doc.text( paper[:authors].sub(Regexp.new('.*' + @nameToHighlight), '') )
                else
                  doc.text(paper[:authors])
                end
                doc.text '. '
                doc.em   paper[:journalName] + ' '
                doc.text paper[:journalDetails]

                #scholar_icon = '<span class="twemoji"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M0 1.75A.75.75 0 0 1 .75 1h4.253c1.227 0 2.317.59 3 1.501A3.744 3.744 0 0 1 11.006 1h4.245a.75.75 0 0 1 .75.75v10.5a.75.75 0 0 1-.75.75h-4.507a2.25 2.25 0 0 0-1.591.659l-.622.621a.75.75 0 0 1-1.06 0l-.622-.621A2.25 2.25 0 0 0 5.258 13H.75a.75.75 0 0 1-.75-.75V1.75zm8.755 3a2.25 2.25 0 0 1 2.25-2.25H14.5v9h-3.757c-.71 0-1.4.201-1.992.572l.004-7.322zm-1.504 7.324.004-5.073-.002-2.253A2.25 2.25 0 0 0 5.003 2.5H1.5v9h3.757a3.75 3.75 0 0 1 1.994.574z"/></svg></span>'
                unless doi.empty?
                  doc.text(' ')
                  doc.a(href: URI.join("http://dx.doi.org/", doi)) do
                    doc.text "[DOI]"
                    #doc.text "#{scholar_icon} DOI"
                    #doc.content.gsub!('&lt;','<')
                    #doc.content.gsub!('&gt;','>')
                  end
                end

		            if @pdfLinks.keys.include?(paper[:title])
                  doc.text(' ')
                  doc.a(href: @pdfLinks[paper[:title]]) { doc.text "[PDF]" }
		            end

                #citation_icon = '<span class="twemoji"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M10.5 5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zm.061 3.073a4 4 0 1 0-5.123 0 6.004 6.004 0 0 0-3.431 5.142.75.75 0 0 0 1.498.07 4.5 4.5 0 0 1 8.99 0 .75.75 0 1 0 1.498-.07 6.005 6.005 0 0 0-3.432-5.142z"/></svg></span>'
                if paper[:citationCount].to_i > @minCitations
                  doc.text(' ')
                  #doc.a(href: paper[:citingPapers], title: "Citations") do
                    doc.span(class: "badge badge-inverse") do
                      doc.test("#{paper[:citationCount]} cites")
                      #doc.test("#{citation_icon} #{paper[:citationCount]} cites")
                    end
                  #end
                end

		            if altmetricDOIs.include?(doi)
                  doc.text(' ')
                  doc.span(class: 'altmetric-embed', 'data-badge-popover':'bottom', 'data-doi': doi)
                end
              end
            end
          end
        end
      end
      return builder.to_html
    end
  end
end
