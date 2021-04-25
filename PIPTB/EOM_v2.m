syms psi(t) phi(t) theta(t) tau(t) mk mw mu rk rw L D g
%psi Driven Wheel | phi Actuating Wheel | theta Upper Body
assume([mk mw mu rk rw L D],'positive')


%g = 9.81;

IU = mu * L^2;
IW = 1/2 * mw * rw^2;
IK = 1/2 * mk * rk^2;

dpsi = diff(psi(t),t);
dphi = diff(phi(t),t);
dtheta = diff(theta(t),t);

%Linear Rail

%Kinetic
TDWL = 1/2*mk*(rk*dpsi)^2 + 1/2*IK*dpsi^2;
TAWL = 1/2*mw*((rk*dpsi)^2 + 2*(rk+rw)*cos(theta(t))*dtheta*(rk*dpsi) + (rk+rw)^2*dtheta^2) + 1/2*IW*(rk/rw*(dpsi-dtheta)-dtheta)^2;
TUBL = 1/2*mu*((rk*dpsi)^2 + 2*L*cos(theta(t))*dtheta*(rk*dpsi) + L^2*dtheta^2) + 1/2*IU*(dtheta)^2;

TL = TDWL+TAWL+TUBL;

%Potential
VDWL = 0;
VAWL = mw*g*(rk+rw)*cos(theta(t));
VUBL = mu*g*L*cos(theta(t));

VL = VDWL+VAWL+VUBL;

%Lagragian
LL = TL-VL;

QL = [rk/rw*tau(t), -rk/rw*tau(t)];
%Q about  psi, theta

dLLdpsi = diff(LL,dpsi);
dLLpsi = diff(LL,psi(t));
dLLdtheta = diff(LL,dtheta);
dLLtheta = diff(LL,theta(t));

eqn1L = diff(dLLdpsi,t)-dLLpsi - QL(1) == 0;
eqn2L = diff(dLLdtheta,t)-dLLtheta - QL(2) == 0;

disp('Linear Rail Eqn #1')
pretty(simplify(eqn1L))
disp('Linear Rail Eqn #2')
pretty(simplify(eqn2L))


%Planetary Rail

%Kinetic
TDWP = 1/2*mk*(rk*dpsi)^2 + 1/2*IK*dpsi^2 + 1/2*mk*(dpsi*rk/D)^2;
TAWP = 1/2*mw*((rk*dpsi)^2 + 2*(rk+rw)*cos(theta(t))*dtheta*(rk*dpsi) + (rk+rw)^2*dtheta^2) + 1/2*IW*(rk/rw*(dpsi-dtheta)-dtheta)^2 + 1/2*mw*(dpsi*rk/D)^2;
TUBP = 1/2*mu*((rk*dpsi)^2 + 2*L*cos(theta(t))*dtheta*(rk*dpsi) + L^2*dtheta^2) + 1/2*IU*(dtheta)^2 + 1/2*mu*(dpsi*rk/D)^2;

TP = TDWP+TAWP+TUBP;

%Potential
VDWP = 0;
VAWP = mw*g*(rk+rw)*cos(theta(t));
VUBP = mu*g*L*cos(theta(t));

VP = VDWP+VAWP+VUBP;

LP = TL-VL;

QP = [rk/rw*tau(t), -rk/rw*tau(t)];
%Q about  psi, theta

dLPdpsi = diff(LP,dpsi);
dLPpsi = diff(LP,psi(t));
dLPdtheta = diff(LP,dtheta);
dLPtheta = diff(LP,theta(t));

eqn1P = diff(dLPdpsi)-dLPpsi - QP(1) == 0;
eqn2P = diff(dLPdtheta)-dLPtheta - QP(2) == 0;

disp('Planetary Rail Eqn #1')
pretty(simplify(eqn1P))
disp('Planetary Rail Eqn #2')
pretty(simplify(eqn2P))