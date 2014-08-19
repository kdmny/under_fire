require 'under_fire/configuration'
require 'builder'

module UnderFire
  # Register an application using client_id (only needs to be done once per application).
  #
  # @see https://developer.gracenote.com/sites/default/files/web/html/index.html#Music%20Web%20API/Registration%20and%20Authentication.html#_Toc344907213
  class Registration
    # @return [String] XML string for query
    attr_reader :query

    # @return [String] Gracenote Client ID
    attr_reader :client_id, :app_userid

    # @param [String] client_id Gracenote Client ID.
    def initialize(client_id, app_userid = nil)
      @client_id = client_id
      @app_userid = app_userid
      @query = build_query
    end

    # Builds XML for REGISTRATION query.
    #
    # @return [String] XML string for REGISTRATION
    def build_query
      builder = Builder::XmlMarkup.new
      xml = builder.QUERIES {
        builder.QUERY(CMD: 'REGISTER'){
          builder.CLIENT client_id
          builder.APP_USERID app_userid
        }
      }
      xml
    end
  end
end
