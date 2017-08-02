module Http.Extra exposing (..)

{-| Convenience functions for working with Http


# Expects

@docs expectJsonResponse, expectValue, expectNothing

-}

import Http exposing (Expect, Request, Response)
import Json.Decode as Decode exposing (Decoder)


{-| Decode a response body as JSON, but keep the rest of the response. Unlike
Http.expecJson, you can decode using a Decoder but still get access to response
headers, status code, etc.
-}
expectJsonResponse : Decoder a -> Expect (Response a)
expectJsonResponse decoder =
    Http.expectStringResponse
        (\response ->
            response.body
                |> Decode.decodeString decoder
                |> Result.map (\a -> { response | body = a })
        )


{-| Complete a request with a predetermined value. Using `Json.Decode.succeed`
fails when the the server doesn't send back valid JSON, as `expectJson` always
attempts to parse the response body as JSON. `expectValue` skips decoding
entirely.
-}
expectValue : a -> Expect a
expectValue a =
    Http.expectStringResponse (\_ -> Ok a)


{-| Complete a request with a `()` value. Skips JSON decoding to always complete
with `()`, regardless of what the server returns.
-}
expectNothing : Expect ()
expectNothing =
    expectValue ()
