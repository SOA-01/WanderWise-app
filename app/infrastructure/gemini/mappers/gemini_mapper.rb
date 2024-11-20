

module WanderWise
    class GeminiMapper
        def initialize(gateway)
            @gateway = gateway
        end

        def find_gemini_data(prompt)
            response = @gateway.gemini_api_call(prompt)
            text = response.first["candidates"].first["content"]["parts"].first["text"]
            text
        end
    end
end
