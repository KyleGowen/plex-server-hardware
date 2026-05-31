# Plex Collection Posterize Mode

Use when the user asks to posterize, apply posters, choose artwork, or make an existing/new collection visually consistent.

1. Search ThePosterDB only for the requested collection and key unmatched titles.
2. Prefer one coherent uploader or set family with collection and item posters.
3. Apply posters through Plex URL upload endpoints.
4. Verify the collection and changed items have updated user poster values.

Do not add missing media or trigger Arr searches unless the user separately asks for fill/complete work.

## Fast Path Notes

- When the user chooses a known TPDb uploader/set, open one poster page from that set and extract the visible `https://images.theposterdb.com/...jpg` URLs plus the `https://theposterdb.com/set/{id}` link from the HTML. This is usually faster than repeated web searches.
- Map TPDb movie poster URLs by the nearby visible title/year text in the poster page HTML. For collection posters, use the nearby `collections/{id}` image URL.
- Apply posters with `POST /library/metadata/{ratingKey}/posters?url={encodedImageUrl}` using the local Plex token.
- Verify with Plex SQLite in one read-only query against `metadata_items.user_thumb_url` for the collection and all changed item rating keys. A non-empty `upload://posters/...` value confirms Plex stored the override.
