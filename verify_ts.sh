sh clean.sh
sh rebuild_ts.sh

cd Languages/TypeScript
git clone https://github.com/iho/der.ts
bun build ./main.ts --outdir ./dist --target browser
bun run main.ts
