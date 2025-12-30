cd Languages/TypeScript
git clone https://github.com/chat-x509/der.ts
bun build ./main.ts --outdir ./dist --target browser
bun run main.ts
