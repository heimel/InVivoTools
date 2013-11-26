function [a, c, P] = discrimin_iterative(DATA, G)

l = size(DATA,2);

X0 = rand(1,2*l);
X = fminsearch('discrimin_iterative_err',X0,[],DATA,G);

a = X(1:(l)); c = X(((l)+1):end);

P = discrimin_iterative_err(X,DATA,G);
