require 'faye/websocket'
require 'json'
require 'date'

module HappinessPoll
  class HappinessBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = {}
      @votes   = {}
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        scope = determine_scope(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          add_client_in_scope ws, scope

          payload = {id: ws.object_id}
          ws.send(create_message('id', payload))
          send_message_to_scope(create_message('joined', state_for_scope(scope)), scope)
        end

        ws.on :message do |event|
          message = JSON.parse(event.data)
          if (message['topic'] == 'vote')
            payload = message['payload']
            add_vote_to_scope(payload['voter'], payload['vote'], payload['voteType'], scope)
            send_message_to_scope(create_message('voted', state_for_scope(scope)), scope)

            # easter egg for the OKE team
            if (scope == "oke" and @votes.has_key?(scope) and @votes[scope].has_key?('happiness') and @votes[scope]['happiness'].is_a? Hash and @votes[scope]['happiness'].keys.length == 7)
              send_message_to_scope(create_message('chatted', {message: "Hi OKE team! I miss you! -The ghost of Scott", date: Date.today}), scope)
            end
          elsif (message['topic'] == 'chat')
            payload = message['payload']
            send_message_to_scope(create_message('chatted', payload), scope)
          end
        end

        ws.on :close do |event|
          remove_voter_from_scope ws.object_id, scope
          remove_client_from_scope ws, scope

          ws = nil
          send_message_to_scope(create_message('exit', state_for_scope(scope)), scope)
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private

    def add_client_in_scope(client, scope)
      @clients[scope] = [] unless @clients.has_key?(scope)
      @clients[scope] << client
    end

    def remove_client_from_scope(client, scope)
      @clients[scope].delete(client) if @clients.has_key?(scope)
    end

    def remove_voter_from_scope(voter, scope)
      if @votes.has_key?(scope)
        @votes[scope].each_key do |vote_type|
          @votes[scope][vote_type].delete(voter) if @votes[scope][vote_type].has_key?(voter)
        end
      end
    end

    def state_for_scope(scope)
      { participants: participants_for_scope(scope), votes: votes_for_scope(scope) }
    end

    def participants_for_scope(scope)
      participants = []
      participants = @clients[scope].map { |c| c.object_id } if @clients.has_key?(scope)
      return participants
    end

    def votes_for_scope(scope)
      votes = {}
      votes = @votes[scope] if @votes.has_key?(scope)
      return votes
    end

    def add_vote_to_scope(voter, vote, vote_type, scope)
      @votes[scope] = {} unless @votes.has_key?(scope)
      @votes[scope][vote_type] = {} unless @votes[scope].has_key?(vote_type)
      @votes[scope][vote_type][voter] = vote
    end

    def create_message(topic, message)
      JSON.generate({ topic: topic, payload: message })
    end

    def sanitize(message)
      json = JSON.parse(message)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end

    def send_message_to_scope(message, scope)
      @clients[scope].each { |client| client.send(message) } if @clients.has_key?(scope)
    end

    def determine_scope(env)
      env['REQUEST_PATH'].gsub('/', '')
    end
  end
end
