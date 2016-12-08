// The MIT License (MIT)
// Copyright (c) 2016 Erik Little

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without
// limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

import Foundation

public extension DiscordEndpoint {
    public static func createDM(with: String, user: String, with token: DiscordToken,
            callback: @escaping (DiscordDMChannel?) -> Void) {
        guard let contentData = encodeJSON(["recipient_id": with])?.data(using: .utf8, allowLossyConversion: false)
                else {
            return
        }

        var request = createRequest(with: token, for: .userChannels, replacing: ["me": user])

        request.httpMethod = "POST"
        request.httpBody = contentData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(String(contentData.count), forHTTPHeaderField: "Content-Length")

        let rateLimiterKey = DiscordRateLimitKey(endpoint: .userChannels, parameters: ["me": user])

        DiscordRateLimiter.executeRequest(request, for: rateLimiterKey, callback: {data, response, error in
            guard let data = data, response?.statusCode == 200 else {
                callback(nil)

                return
            }

            guard let stringData = String(data: data, encoding: .utf8), let json = decodeJSON(stringData),
                case let .dictionary(channel) = json else {
                    callback(nil)

                    return
            }

            callback(DiscordDMChannel(dmObject: channel))
        })
    }

    public static func getDMs(user: String, with token: DiscordToken,
            callback: @escaping ([String: DiscordDMChannel]) -> Void) {
        var request = createRequest(with: token, for: .userChannels, replacing: ["me": user])

        request.httpMethod = "GET"

        let rateLimiterKey = DiscordRateLimitKey(endpoint: .userChannels, parameters: ["me": user])

        DiscordRateLimiter.executeRequest(request, for: rateLimiterKey, callback: {data, response, error in
            guard let data = data, response?.statusCode == 200 else {
                callback([:])

                return
            }

            guard let stringData = String(data: data, encoding: .utf8), let json = decodeJSON(stringData),
                case let .array(channels) = json else {
                    callback([:])

                    return
            }

            callback(DiscordDMChannel.DMsfromArray(channels as! [[String: Any]]))
        })
    }

    public static func getGuilds(user: String, with token: DiscordToken,
            callback: @escaping ([String: DiscordUserGuild]) -> Void) {
        var request = createRequest(with: token, for: .userGuilds, replacing: ["me": user])

        request.httpMethod = "GET"

        let rateLimiterKey = DiscordRateLimitKey(endpoint: .userGuilds, parameters: ["me": user])

        DiscordRateLimiter.executeRequest(request, for: rateLimiterKey, callback: {data, response, error in
            guard let data = data, response?.statusCode == 200 else {
                callback([:])

                return
            }

            guard let stringData = String(data: data, encoding: .utf8), let json = decodeJSON(stringData),
                case let .array(guilds) = json else {
                    callback([:])

                    return
            }

            callback(DiscordUserGuild.userGuildsFromArray(guilds as! [[String: Any]]))
        })
    }
}