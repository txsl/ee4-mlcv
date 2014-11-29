function H = getE(X)

distrib = histc(X(:,1:end), unique(X(:,end)));
p = distrib/sum(distrib);
H = p .* log(p);
H = -sum(H);

end