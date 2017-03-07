-module(commits).
-export([get/2,write/3, test/0]).

get(Hash, Commits) ->
    true = is_binary(Hash),
    ID = hash2ID(Hash),
    {X, Leaf, Proof} = trie:get(ID, Commits, existence),
    V = case Leaf of
	    empty -> empty;
	    L -> 
		Y = leaf:value(L),
		AB = constants:acc_bits(),
		<<Z:AB>> = Y,
		Z
	end,
    {X, V, Proof}.
write(N, Hash, Commits) ->
    ID = hash2ID(Hash),
    AB = constants:acc_bits(),
    trie:put(ID, <<N:AB>>, Commits, existence).
	     
hash2ID(X) -> 
    S = size(X),
    S = trie_hash:hash_depth(),
    hash2ID(X, 0).
hash2ID(<<>>, N) -> N;
hash2ID(<<X, Y/binary>>, N) ->
    M = (N*256) + X,
    hash2ID(Y, M).


test() ->
    C = hash:doit(2),
    {_, empty, _} = get(C, 0),
    ID = 1,
    NewLoc = write(ID, C, 0),
    NewLoc2 = write(ID, hash:doit(4), NewLoc),
    {_, ID, _} = get(C, NewLoc2),
    {_, empty, _} = get(C, 0),
    success.
