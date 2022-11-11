function [matrix] = makeM(rows,cols,vals)
%to use:
%type "name of matrix" = makeM("number of rows", "number of columns", [
%the the open brackets is necessary!!
%then paste in the matrix from the google doc
%type ]) then hit enter
matrix = reshape(vals,[cols,rows]);
matrix = matrix';
end

