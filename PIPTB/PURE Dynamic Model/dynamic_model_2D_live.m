syms Xk Zk Xa Za Xw Zw ...
    phi(t) th(t) psi(t)...
    mk mw ma rk rw ra l Jw Jk Ja g

% define rigid body coordinates
Xk = rk*phi;
Zk = rk;

Xa = Xk+l*sin(th);
Za = Zk+l*cos(th);

Xw = Xk+(rk+rw)*sin(th);
Zw = Zk+(rk+rw)*cos(th);

dXk = diff(Xk,t);
dZk = diff(Zk,t);

dXa = diff(Xa,t);
dZa = diff(Za,t);

dXw = diff(Xw,t);
dZw = diff(Zw,t);

psi = rk/rw*(dphi-dth)-dth;

%% 
% ball
Tk = 1/2*mk*(dXk^2+dZk^2)+1/2*Jk*dphi^2;
Vk = mk*g*Zk;

