require 'gemini-ai'

module WanderWise
    class GeminiAPI
        def initialize
            environment = ENV['RACK_ENV'] || 'development'
            secrets_file_path = './config/secrets.yml'
            raise "secrets.yml file not found for #{environment} environment." unless File.exist?(secrets_file_path)
    
            secrets = YAML.load_file(secrets_file_path)
            @client_key = 'AIzaSyCgj52ZjGWGWrW--aa1AHt0k0fqSg_ZZ5g'
            
            @client = Gemini.new(
                credentials: {
                  service: 'generative-language-api',
                  api_key: @client_key
                },
                options: { model: 'gemini-pro', server_sent_events: true }
              )
              
        end

        def gemini_api_call(prompt)

            result = @client.stream_generate_content({contents: { role: 'user', parts: { text: prompt } }})
            result
          end
    end
end