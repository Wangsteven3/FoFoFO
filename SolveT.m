function [T] = SolveT(C, Sx, Sy, X, Y, L)
%{
Matrix dimentions:
C = j * m
Sx = j * 3 (if one pin, one roller)
Sy = j * 3 (if one pin, one roller)
X = 1 * j
Y = 1 * j
L = m+3 * 1
%}

%initiallizes A as a bunch of 0s plus the S's:
[rows, cols] = size(C);
A = zeros(2 * rows, cols);
S = [Sx; Sy];
A = [A, S];

%makes an array of [1, 2, ... , rows] for indexing later:
indexer = 1:rows;

%creates A:
for i = 1:cols
    %finds all values we will use to plug into A:
    Xvals = X(logical(C(:,i)'));
    X1minusX2 = Xvals(1) - Xvals(2);
    X2minusX1 = - X1minusX2;
    Yvals = Y(logical(C(:,i)'));
    Y1minusY2 = Yvals(1) - Yvals(2);
    Y2minusY1 = - Y1minusY2;
    r = sqrt(X1minusX2^2 + Y1minusY2^2);
    
    %based on pattern in how A is set up:
    a = X2minusX1 / r;
    b = X1minusX2 / r;
    c = Y2minusY1 / r;
    d = Y1minusY2 / r;
    
    %insert into A column by column:
    indexes = indexer(logical(C(:,i)'));
    A(indexes(1),i) = a;
    A(indexes(2),i) = b;
    A(indexes(1) + rows,i) = c;
    A(indexes(2) + rows,i) = d;
end
%Uncomment if you want to see what A looks like:
%A

%Solve for T now:
T = A \ L; %functionally the same but faster than inv(A) * L
end

