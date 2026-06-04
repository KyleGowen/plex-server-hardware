# Plex Collection Collection-Only Mode

Use when the user asks to create or update Plex collection membership for items that are already in Plex.

1. Resolve the collection membership with the minimum local checks needed.
2. Query Plex sections and match available library items.
3. Create or update the Plex collection membership.
4. Verify the collection children after the update.

Do not fill missing media or research/apply posters unless the user asks for those actions.

## Fast Path Notes

- For large collections, query the whole movie/show section once and match locally by normalized title plus year. Avoid one Plex `/search` call per title unless there is ambiguity.
- Before creating a collection, list existing collection titles in the target section. Reuse an existing user-facing title instead of creating a near-duplicate such as `Middle-earth` vs `Middle-earth Collection`.
- For mixed movie/show themes, create same-title section-local collections in Movies and TV Shows. Verify each collection from its own section; do not assume every Plex client will display TV children inside a Movies collection page.
