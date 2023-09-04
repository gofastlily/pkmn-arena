#!/usr/bin/env nix-shell 
#! nix-shell -i bash --pure
#! nix-shell -p bash cacert gnumake gcc git rgbds gawk which haskellPackages.cryptohash-sha1

# The -c flag runs make clean
if [ "$1" == "-c" ]; then
  make clean
fi
make

# Document the free space
echo "\`\`\`" > FREE_SPACE.md
tools/free_space.awk BANK=all pkmn_arena.map >> FREE_SPACE.md
echo "\`\`\`" >> FREE_SPACE.md

# Generate a file hash
echo "\`\`\`" > HASHES.md
sha1sum pkmn_arena.gbc pkmn_arena.sym pkmn_arena.map >> HASHES.md
sha1sum pkmn_arena_debug.gbc pkmn_arena_debug.sym pkmn_arena_debug.map >> HASHES.md
echo "\`\`\`" >> HASHES.md
