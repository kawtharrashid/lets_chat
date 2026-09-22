Recommendation: Unify timestamp semantics

Current concern:
- `MessageEntity.createdAt` may be set from the client clock when messages are created locally while Firestore stores server timestamps for persistence.

Problems this causes:
- Inconsistent ordering between locally generated messages and server-synced messages.
- Incorrect time display if client clock differs from server.

Suggested approaches:
- Use Firestore server timestamps (`FieldValue.serverTimestamp()`) as the canonical source of truth. Assign a temporary local placeholder for optimistic UI, then replace with server value when the write completes.
- Store both `createdAtLocal` and `createdAtServer` if you need immediate UX and accurate server ordering. Use server timestamp for ordering and persistent display when available.
- Normalize `MessageEntity.createdAt` to be nullable until server-provided timestamp arrives; display a local "sending" indicator if needed.

Next steps:
- Review `chat_remote_datasource` and `chat_repository_impl` to ensure writes use server timestamp and reads map server timestamp to `MessageEntity`.
- Add optimistic update handling in `ChatCubit` so the UI shows messages immediately and reconciles timestamps on server sync.
