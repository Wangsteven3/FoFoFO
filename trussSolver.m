%{
matrix dimentions
C = j * m
Sx = j * 3 (if one pin, one roller)
Sy = j * 3 (if one pin, one roller)
X = 1 * j
Y = 1 * j
L = m+3 * 1
%}

%initiallizes A as a bunch of 0s plus the S's
[rows, cols] = size(C);
A = zeros(2 * rows, cols);
S = [Sx; Sy];
A = [A, S];

%makes an array of [1, 2, ... , rows] for indexing later
indexer = 1:rows;
%makes an array for the Pcrit of each member
Pcrit = zeros(cols,1);
%initializes values for finding the cost
Rtot = 0;
numJoints = rows;

%creates A:
for i = 1:cols
    %finds all values we will use to plug into A
    Xvals = X(logical(C(:,i)'));
    X1minusX2 = Xvals(1) - Xvals(2);
    X2minusX1 = - X1minusX2;
    Yvals = Y(logical(C(:,i)'));
    Y1minusY2 = Yvals(1) - Yvals(2);
    Y2minusY1 = - Y1minusY2;
    r = sqrt(X1minusX2^2 + Y1minusY2^2);
    
    %based on pattern in how A is set up
    a = X2minusX1 / r;
    b = X1minusX2 / r;
    c = Y2minusY1 / r;
    d = Y1minusY2 / r;
    
    %insert into A column by column
    indexes = indexer(logical(C(:,i)'));
    A(indexes(1),i) = a;
    A(indexes(2),i) = b;
    A(indexes(1) + rows,i) = c;
    A(indexes(2) + rows,i) = d;
    
    %calculates the Pcrit of the member using p = 2945 / (r ^ 2)
    p = 2945 / r ^ 2;
    Pcrit(i) = p;
    
    %add the radius of the member to the total length of the bridge
    Rtot = Rtot + r;
end

%solve for T now
T = A \ L; %functionally the same but faster than inv(A) * L

%find the point of faliure
Wl = sum(L); %magnitute of the live load
R = T / Wl; %finds each member's R value
R = R(1:end - 3); %get rid of the pin and roller tension values
Wf = - Pcrit ./ R; %finds each member's faliure load
maxPcrit = max(Wf); %to make sure certain members are ignored in the calculation for weakest
for i = 1:cols %Only members in compression will bend, so weed out any in tension
    if (Wf(i) <= 0) || (Wf(i) <= (Wl / 1000))
        %(Wf(i) <= 0) tests for members in tension
        %(Wf(i) <= (Wl / 1000)) tests for members with negligible forces
        %aka zero force members that matlab still calculates a value for
        Wf(i) = maxPcrit; %replaces them both with the max Pcrit value so they wont be picked
    end
end
critVal = min(Wf); %finds breaking point of weakest link
critMember = Wf == critVal; %finds weakest link
critMember = find(critMember);
critMember = critMember(1); %in case there are multiple weakest links, only want one

%calculate the cost with $10/joint + $1/inch
totCost = 10 * numJoints + Rtot;
%calculate max load/cost ratio
loadCostRatio = critVal / totCost; %the larger the better!

%format and print everything:
fprintf("\\%% EK301, Section A5, Group FoFoFo: ")
fprintf("Linden A., Joseph C., Stephen W., Kevin C., 11/11/2022.\n")
fprintf("Load: %.3g oz\n", Wl)
fprintf("Member forces in oz:\n")
for i = 1:cols
    fprintf("m%d: %.3g ", i, abs(T(i)))
    if abs(T(i)) == T(i)
        fprintf("(T)\n")
    else
        fprintf("(C)\n")
    end
end
fprintf("Reaction forces in oz:\n")
fprintf("Sx1: 0\n") %will always be zero
fprintf("Sy1: %.3g\n", T(end - 1))
fprintf("Sy2: %.3g\n", T(end))
fprintf("Theoretical max load: %.3g oz\n", critVal)
fprintf("Critical member: m%d\n", critMember)
fprintf("Cost of truss: $%.2f\n", totCost)
fprintf("Theoretical max load/cost ratio in oz/$: %g\n", loadCostRatio)
