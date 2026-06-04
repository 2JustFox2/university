function F = system( x )
    F(1) = sin(x(1)+x(2))-1.24*x(1)-0.1;
    F(2) = x(1)^2+x(2)^2-1;
end

