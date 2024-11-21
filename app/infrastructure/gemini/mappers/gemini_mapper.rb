

module WanderWise
    class GeminiMapper
        def initialize(gateway)
            @gateway = gateway
        end

        def find_gemini_data(prompt)
            response = @gateway.gemini_api_call(prompt)
            text = ""
            for i in 0..response.length-1
                text += response[i]["candidates"].first["content"]["parts"].first["text"]
            end
            text
        end
    end
end
