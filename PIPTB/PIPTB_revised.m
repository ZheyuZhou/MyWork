syms psi(t) phi(t) theta(t) tau(t) mk mw mu rk rw L d g
%psi Driven Wheel: K| phi Actuating Wheel: W| theta Upper Body: U
assume([mk mw mu rk rw L d],'positive')

%g = 9.81;

IU = mu * L^2;
IW = 1/2 * mw * rw^2;
IK = 1/2 * mk * rk^2;

dpsi = diff(psi(t),t);
dphi = diff(phi(t),t);
dtheta = diff(theta(t),t);

% position for K W U
KL = [psi(t)*rk, 0, 0];
KC = [psi(t)*rk, d*cos(atan(0.5* (psi(t)*rk) /d)*2), 0];

WL = [psi(t)*rk + sin(theta)*(rk+rw), 0, cos(theta)*(rk+rw)];
WC = [psi(t)*rk + sin(theta)*(rk+rw), d*cos(atan(0.5* (psi(t)*rk + sin(theta)*(rk+rw)) /d)*2), cos(theta)*(rk+rw)];

UL = [psi(t)*rk + sin(theta)*L, 0, cos(theta)*L];
UC = [psi(t)*rk + sin(theta)*L, d*cos(atan(0.5* (psi(t)*rk + sin(theta)*L) /d)*2), cos(theta)*L]; 

dKL = diff(KL);
dKC = diff(KC);

dWL = diff(WL);
dWC = diff(WC);

dUL = diff(UL);
dUC = diff(UC);

%Kinetics Linear L | Circular C
TKL = 1/2*mk*dKL*(dKL.') + 1/2*IK*dpsi.^2;
TKC = 1/2*mk*dKC*(dKC.') + 1/2*IK*dpsi.^2;

TWL = 1/2*mw*dWL*(dWL.') + 1/2*IW*dpsi.^2;
TWC = 1/2*mw*dWC*(dWC.') + 1/2*IW*dpsi.^2;

TUL = 1/2*mu*dUL*(dUL.') + 1/2*IU*dtheta.^2;
TUC = 1/2*mu*dUC*(dUC.') + 1/2*IU*dtheta.^2;

TL = TKL + TWL + TUL;
TC = TKC + TWC + TUC;

%Potential Linear L | Circular C
VK = 0;

VW = mw*g*(rk+rw)*cos(theta(t));

VU = mu*g*L*cos(theta(t));

V = VK+VW+VU;

%Lagrangian Analysis Linear L | Circular C
LL = TL - V;
LC = TC - V;

%Q about  psi, theta
Q = [rk/rw*tau(t), -rk/rw*tau(t)];

%Linear EOMs
dLLdpsi = diff(LL,dpsi);
dLLpsi = diff(LL,psi(t));
dLLdtheta = diff(LL,dtheta);
dLLtheta = diff(LL,theta(t));

eqn1L = diff(dLLdpsi,t)-dLLpsi - Q(1) == 0;
eqn2L = diff(dLLdtheta,t)-dLLtheta - Q(2) == 0;

disp('Linear Rail Eqn #1')
pretty(simplify(eqn1L))
disp('Linear Rail Eqn #2')
pretty(simplify(eqn2L))

%Circular EOMs
dLCdpsi = diff(LC,dpsi);
dLCpsi = diff(LC,psi(t));
dLCdtheta = diff(LC,dtheta);
dLCtheta = diff(LC,theta(t));

eqn1C = diff(dLCdpsi,t)-dLCpsi - Q(1) == 0;
eqn2C = diff(dLCdtheta,t)-dLCtheta - Q(2) == 0;

disp('Planetary Rail Eqn #1')
pretty(simplify(eqn1C))
disp('Planetary Rail Eqn #2')
pretty(simplify(eqn2C))
