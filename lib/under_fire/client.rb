require 'under_fire/album_search'
require 'under_fire/album_toc_search'
require 'under_fire/album_fetch'
require 'under_fire/api_request'
require 'under_fire/api_response'
require 'under_fire/configuration'

# require 'pry'

module UnderFire
  # Public interface to UnderFire's functionality.
  #
  # @example
  #   client = UnderFire::Client.new
  #   client.album_search(:artist => 'Miles Davis') #=> lots of results
  #
  #   client = UnderFire::Client.new
  #   client.find_by_toc space_delimited_toc_offsets
  class Client
    include UnderFire

    # the user id to make calls on behalf of
    attr_reader :user_id

    attr_reader :format

    def initialize(format = "json", user_id = nil)
      @user_id = user_id
      @format = format
    end

    def create_radio(params)
      params[:user] ||= self.user_id
      params.merge!({client: Configuration.instance.client_id, return_settings: 1, select_extended: "link", return_count: 50})
      response = APIRequest.get(params, Configuration.instance.api_url(@format,"radio/create"))
      parse_response(response)
    end

    def find_field_values(fieldname, params = {country: "usa", lang: "en"})
      params[:user] ||= self.user_id
      params[:fieldname] = fieldname
      params.merge!({client: Configuration.instance.client_id, return_settings: 1, select_extended: "link", return_count: 50})
      response = APIRequest.get(params, Configuration.instance.api_url(@format, "radio/fieldvalues"))
      parse_response(response)
    end

    # Searches for album using provided toc offsets.
    # @return [APIResponse]
    # @see UnderFire::AlbumTOCSearch
    def find_by_toc(*offsets)
      offsets = offsets.join(" ")
      search = AlbumTOCSearch.new(:toc => offsets)
      response = APIRequest.post(search.query, Configuration.instance.api_url(@format))
      parse_response(response)
    end

    def parse_response(resp)
      if @format == "json"
        JSON.parse(resp.body)
      else
        APIResponse.new(resp.body)
      end
    end

    # Finds album using one or more of :artist, :track_title and :album_title
    # @return [APIResponse]
    # @see UnderFire::AlbumSearch Description of arguments.
    def find_album(args)
      search = AlbumSearch.new(args)
      response = APIRequest.post(search.query, Configuration.instance.api_url(@format))
      parse_response(response)
    end

    # Fetches album with given album :gn_id or track :gn_id
    # @return [APIResponse]
    # @see UnderFire::AlbumFetch Description of arguments.
    def fetch_album(args)
      search = AlbumFetch.new(args)
      response = APIRequest.post(search.query, Configuration.instance.api_url(@format))
      parse_response(response)
    end

    # Registers user with given client_id
    # @return [APIResponse]
    # @see UnderFire::Registration Description of arguments
    def register(app_userid = nil)
      search = Registration.new(Configuration.instance.client_id, app_userid)
      response = APIRequest.post(search.query, Configuration.instance.api_url(@format))
      parse_response(response)
    end

    # Fetches cover art using results of query.
    # @param [APIResponse] response
    def fetch_cover(response, file_name)
      res = response.to_h
      response_url = res['RESPONSE']['ALBUM']['URL']
      title = res['RESPONSE']['ALBUM']['TITLE']
      file_name = file_name || "#{title}-cover.jpg"

      APIRequest.get_file(response_url, filename)
    end
  end
end
