require 'rubygems'
require 'bundler'
require 'cgi'
Bundler.require :default
require './models'

Tilt.prefer Tilt::RedcarpetTemplate
Slim::EmbeddedEngine.default_options[:markdown]= { :no_intra_emphasis   => true,
                                                   :fenced_code_blocks  => true,
                                                   :autolink            => true,
                                                   :lax_html_blocks     => true }

def replace_tag(result, tag, attr)
  if tag[attr] and (not tag[attr]=~/http|\/\//)
    resname = tag[attr]
    gist_meta = result["files"][resname]
    if gist_meta
      res_url = gist_meta["raw_url"]
      tag[attr]=res_url
    end
  end
end

helpers do
  def gist_id
    params[:gist_id]
  end
  def encoded_uri
    CGI.escape("http://www.hackerdeck.net/#{@gist_id}")
  end
end

class GistRequest
  include HTTParty
  base_uri "https://api.github.com"
  def initialize(u,p)
    @auth = {:username=>u, :password=>p}
  end
  def get_gist(gist_id, etag="")
    response=self.class.get("/gists/#{gist_id}",{:basic_auth=>@auth,:headers=>{"If-None-Match"=>etag, "User-Agent"=>"HackerDeck"}})
  end
end
gistRequest = GistRequest.new(ENV["GH_USER"],ENV["GH_PASS"])

get '/not_found' do
  "Are you sure you got the right gist? May be the gist is ill formatted"
end

get '/:gist_id' do
  @gist=Gist.where(:gist_number=>params[:gist_id]).first
  etag = (@gist && @gist.etag) || ""
  result = gistRequest.get_gist params[:gist_id],etag
  unless [200,304].index(result.code)
    redirect '/not_found'
    return
  end
  slim_content=nil
  if(@gist and result.code==304)
    puts "serving from cache"
    slim_content=@gist.content
    @user=@gist.username
    @replaced_content=@gist.processed
  else
    @user = result["owner"]["login"]
    slim_file=result["files"]["slides.slim"]
    unless slim_file
      redirect '/not_found'
      return
    end
    slim_content = slim_file["content"]
    begin
      @content=Nokogiri::HTML(slim(slim_content,:layout=>:layout))
      @content.css("script").each { |tag| replace_tag result,tag,"src" }
      @content.css("link").each { |tag| replace_tag result,tag,"href" }
      @content.css("img").each { |tag| replace_tag result,tag,"src" }
      @replaced_content=@content.to_html
      if @gist
        @gist.update_attributes({:content=>slim_content,:etag=>result.headers["etag"],:processed=>@replaced_content})
      else
        @gist=Gist.create({:content=>slim_content,
                           :gist_number=>params[:gist_id], 
                           :etag=>result.headers["etag"], 
                           :username=>result["owner"]["login"],
                           :processed=>@replaced_content})
      end
    rescue Exception => e
      puts e.inspect
      puts e.stacktrace.inspect
      redirect '/not_found'
      return
    end
  end
  @replaced_content
end
get '/' do
  redirect '/4576193'
end
