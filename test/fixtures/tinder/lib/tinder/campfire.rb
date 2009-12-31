module Tinder
  
  # == Usage
  #
  #   campfire = Tinder::Campfire.new 'mysubdomain'
  #   campfire.login 'myemail@example.com', 'mypassword'
  #
  #   room = campfire.create_room 'New Room', 'My new campfire room to test tinder'
  #   room.speak 'Hello world!'
  #   room.destroy
  #
  #   room = campfire.find_room_by_guest_hash 'abc123', 'John Doe'
  #   room.speak 'Hello world!'
  class Campfire
    attr_reader :subdomain, :uri

    # Create a new connection to the campfire account with the given +subdomain+.
    #
    # == Options:
    # * +:ssl+: use SSL for the connection, which is required if you have a Campfire SSL account.
    #           Defaults to false
    # * +:proxy+: a proxy URI. (e.g. :proxy => 'http://user:pass@example.com:8000')
    #
    #   c = Tinder::Campfire.new("mysubdomain", :ssl => true)
    def initialize(subdomain, options = {})
      options = { :ssl => false }.merge(options)
      @cookie = nil
      @subdomain = subdomain
      @uri = URI.parse("#{options[:ssl] ? 'https' : 'http' }://#{subdomain}.campfirenow.com")
      if options[:proxy]
        uri = URI.parse(options[:proxy])
        @http = Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)
      else
        @http = Net::HTTP
      end
      @logged_in = false
    end
    
    # Log in to campfire using your +email+ and +password+
    def login(email, password)
      unless verify_response(post("login", :email_address => email, :password => password), :redirect_to => url_for(:only_path => false))
        raise Error, "Campfire login failed"
      end
      # ensure that SSL is set if required on this account
      raise SSLRequiredError, "Your account requires SSL" unless verify_response(get, :success)
      @logged_in = true
    end
    
    # Returns true when successfully logged in
    def logged_in?
      @logged_in == true
    end
  
    def logout
      returning verify_response(get("logout"), :redirect) do |result|
        @logged_in = !result
      end
    end
    
    # Get an array of all the available rooms
    # TODO: detect rooms that are full (no link)
    def rooms
      Hpricot(get.body).search("//div.room").collect do |a|
        name = a.search("//h2/a").inner_html.strip
        name = a.search("//h2").inner_html.strip if name.empty?
        Room.new(self, room_id_from_element(a.attributes['id']), name)
      end
    end
  
    # Find a campfire room by name
    def find_room_by_name(name)
      rooms.detect {|room| room.name == name }
    end

    # Find a campfire room by its guest hash
    def find_room_by_guest_hash(hash, name)
      res = post(hash, :name => name)

      Room.new(self, room_id_from_url(res['location'])) if verify_response(res, :redirect)
    end
    
    # Creates and returns a new Room with the given +name+ and optionally a +topic+
    def create_room(name, topic = nil)
      find_room_by_name(name) if verify_response(post("account/create/room?from=lobby", {:room => {:name => name, :topic => topic}}, :ajax => true), :success)
    end
    
    def find_or_create_room_by_name(name)
      find_room_by_name(name) || create_room(name)
    end
    
    # List the users that are currently chatting in any room
    def users(*room_names)
      users = Hpricot(get.body).search("div.room").collect do |room|
        if room_names.empty? || room_names.include?((room/"h2/a").inner_html)
          room.search("//li.user").collect { |user| user.inner_html }
        end
      end
      users.flatten.compact.uniq.sort
    end
    
    # Get the dates of the available transcripts by room
    #
    #   campfire.available_transcripts
    #   #=> {"15840" => [#<Date: 4908311/2,0,2299161>, #<Date: 4908285/2,0,2299161>]}
    #
    def available_transcripts(room = nil)
      url = "files%2Btranscripts"
      url += "?room_id#{room}" if room
      transcripts = (Hpricot(get(url).body) / ".transcript").inject({}) do |result,transcript|
        link = (transcript / "a").first.attributes['href']
        (result[room_id_from_url(link)] ||= []) << Date.parse(link.scan(/\/transcript\/(\d{4}\/\d{2}\/\d{2})/).to_s)
        result
      end
      room ? transcripts[room.to_s] : transcripts
    end
    
    # Is the connection to campfire using ssl?
    def ssl?
      uri.scheme == 'https'
    end
  
  private
  
    def room_id_from_url(url)
      url.scan(/room\/(\d*)/).to_s
    end
    
    def room_id_from_element(element)
      element.split("_").last
    end

    def url_for(*args)
      options = {:only_path => true}.merge(args.last.is_a?(Hash) ? args.pop : {})
      path = args.shift
      "#{options[:only_path] ? '' : uri}/#{path}"
    end

    def post(path, data = {}, options = {})
      perform_request(options) do
        returning Net::HTTP::Post.new(url_for(path)) do |request|
          if options[:multipart]
            request.body = data
          else
            request.set_form_data(flatten(data))
          end
        end
      end
    end
  
    def get(path = nil, options = {})
      perform_request(options) { Net::HTTP::Get.new(url_for(path)) }
    end
  
    def prepare_request(request, options = {})
      returning request do
        request.add_field 'User-Agent', "Tinder (http://tinder.rubyforge.org)"
        request.add_field 'Cookie', @cookie if @cookie
        request.add_field 'X-Requested-With', 'XMLHttpRequest'
        if options[:ajax]
          request.add_field 'X-Prototype-Version', '1.5.1.1'
        end
        if options[:multipart]
          request.add_field 'Content-Type', 'multipart/form-data, boundary=' + Multipart::MultipartPost::BOUNDARY + " "
        else
          request.add_field 'Content-Type', 'application/x-www-form-urlencoded'
        end
      end
    end
    
    def perform_request(options = {}, &block)
      @request = prepare_request(yield, options)
      http = @http.new(uri.host, uri.port)
      http.use_ssl = ssl?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if ssl?
      @response = returning http.request(@request) do |response|
        @cookie = response['set-cookie'] if response['set-cookie']
      end
    end
  
    # flatten a nested hash (:room => {:name => 'foobar'} to 'user[name]' => 'foobar')
    def flatten(params)
      params = params.dup
      params.stringify_keys!.each do |k,v| 
        if v.is_a? Hash
          params.delete(k)
          v.each {|subk,v| params["#{k}[#{subk}]"] = v }
        end
      end
    end

    def verify_response(response, options = {})
      if options.is_a?(Symbol)
        codes = case options
        when :success; [200]
        when :redirect; 300..399
        else raise(ArgumentError, "Unknown response #{options}")
        end
        codes.include?(response.code.to_i)
      elsif options[:redirect_to]
        verify_response(response, :redirect) && response['location'] == options[:redirect_to]
      else
        false
      end
    end
    
  end
end
