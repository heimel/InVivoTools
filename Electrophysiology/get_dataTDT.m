function data = get_dataTDT(X, interval)
data=X(find(X>=interval(1)&X<=interval(2)));