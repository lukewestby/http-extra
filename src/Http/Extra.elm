module Http.Extra
    exposing
        ( NoContent(..)
        , expectJsonResponse
        , expectNoContent
        , expectValue
        )

{-| Convenience functions for working with Http


# Types

@docs NoContent


# Expects

@docs expectJsonResponse, expectValue, expectNoContent

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
                |> Result.mapError Decode.errorToString
                |> Result.map
                    (\a ->
                        { body = a
                        , url = response.url
                        , status = response.status
                        , headers = response.headers
                        }
                    )
        )


{-| Complete a request with a predetermined value. Using `Json.Decode.succeed`
fails when the the server doesn't send back valid JSON, as `expectJson` always
attempts to parse the response body as JSON. `expectValue` skips decoding
entirely.
-}
expectValue : a -> Expect a
expectValue a =
    Http.expectStringResponse (\_ -> Ok a)


{-| A value representing a response that has no content. Like such a response,
this value contains no information and has one value.
-}
type NoContent
    = NoContent


{-| Complete a request with `NoContent` value. Skips JSON decoding to always
complete with `NoContent`, regardless of what the server returns.
-}
expectNoContent : Expect NoContent
expectNoContent =
    expectValue NoContent
