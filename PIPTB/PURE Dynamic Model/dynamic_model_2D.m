function [A,B,C,D] = dynamic_model_2D(mk, mw, ma, rk, rw, ra, l, Jw, Jk, Ja)
    
    %% define parameters
    syms Xk Zk Xa Za Xw Zw ...
        phi dphi ddphi th dth ddth...
        tau...
        %mk mw ma rk rw ra l Jw Jk Ja g
    g = 9.81;
    %% nonlinear EOMs
    Eq1 = -ddphi*(rk^2*(ma+mk+mw)+Jk)+rk*((l*ma+mw*(rk+rw))*(dth^2*sin(th)-...
        ddth*cos(th))+(Jw*rk*(ddth-ddphi)+rw*(Jw*ddth+tau))/rw^2);

    Eq2 = l*ma*(-g*sin(th)+rk*cos(th)*ddphi+l*ddth)+(Ja+Jw)*ddth+mw*(rk+rw)*...
        (-g*sin(th))+rk*cos(th)*ddphi+(rk+rw)*ddth+(rk*(Jw*rk*(ddth-ddphi)...
        +rw*(Jw*(2*ddth-ddphi)+tau)))/rw^2;

    Sol = solve(Eq1==0,Eq2==0,ddth,ddphi);

    %% state space formulation
    % x1 = th, x2 = dth
    % x3 = phi, x4 = dphi
    % q = [x1; x2; x3; x4]

    syms x1 x2 x3 x4

    fth1 = subs(Sol.ddth,{th,dth,phi,dphi},{x1,x2,x3,x4});
    fth2 = subs(Sol.ddphi,{th,dth,phi,dphi},{x1,x2,x3,x4});

    % dq = [x2; fth1; x4; fth2]
    dq = [x2; fth1; x4; fth2];
    A = jacobian(dq,[x1 x2 x3 x4]);
    A = subs(A,{x1 x2 x3 x4 tau},{ 0 0 0 0 0});
    A = double(vpa(A,3));
    B = jacobian(dq,tau);
    B = subs(B,{x1 x2 x3 x4 tau},{ 0 0 0 0 0});
    B = double(vpa(B,3));
    C = eye(4);
    D = zeros(4,1);
    
end

