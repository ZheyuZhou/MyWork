syms psi(t) phi(t) theta(t) mk mw mu rk rw L D tau(t)
%psi Driven Wheel | phi Actuating Wheel | theta Upper Body
assume([rk rw L D],'positive')

g = 9.81;

IU = mu * L^2;
IW = 1/2 * mw * rw^2;
IK = 1/2 * mk * rk^2;

dphi = diff(phi(t),t);
dpsi = diff(psi(t),t);
dtheta = diff(omg(t),t);

%Linear Rail

%Kinetic
TDWL = 1/2*mk*(rk*dphi)^2 + 1/2*IK*dphi^2;
TAWL = 1/2*mw*((rk*dphi)^2 + 2*(rk+rw)*cos(omg(t))*dtheta*(rk*dphi) + (rk+rw)^2*dtheta^2) + 1/2*IW*(rk/rw*(dphi-dtheta)-dtheta)^2;
TUBL = 1/2*mu*((rk*dphi)^2 + 2*L*cos(omg(t))*dtheta*(rk*dphi) + L^2*dtheta^2) + 1/2*IU*(dtheta)^2;

TL = TDWL+TAWL+TUBL;

%Potential
VDWL = 0;
VAWL = mw*g*(rk+rw)*cos(omg(t));
VUBL = mu*g*L*cos(omg(t));

VL = VDWL+VAWL+VUBL;

LL = TL-VL;

QL = [rk/rw*tau(t), -rk/rw*tau(t)];
%Q about  phi, omega

dLLdphi = diff(LL,dphi);
dLLphi = diff(LL,phi(t));
dLLdomg = diff(LL,dtheta);
dLLomg = diff(LL,omg(t));

eqn1L = diff(dLLdphi)-dLLphi == QL(1);
eqn2L = diff(dLLdomg)-dLLomg == QL(2);



disp('Linear Rail Eqn #1')
pretty(simplify(eqn1L))
disp('Linear Rail Eqn #2')
pretty(simplify(eqn2L))

%Planetary Rail

%Kinetic
TDWP = 1/2*mk*(rk*dphi)^2 + 1/2*IK*dphi^2 + 1/2*mk*(dphi*rk/D)^2;
TAWP = 1/2*mw*((rk*dphi)^2 + 2*(rk+rw)*cos(omg(t))*dtheta*(rk*dphi) + (rk+rw)^2*dtheta^2) + 1/2*IW*(rk/rw*(dphi-dtheta)-dtheta)^2 + 1/2*mw*(dphi*rk/D)^2;
TUBP = 1/2*mu*((rk*dphi)^2 + 2*L*cos(omg(t))*dtheta*(rk*dphi) + L^2*dtheta^2) + 1/2*IU*(dtheta)^2 + 1/2*mu*(dphi*rk/D)^2;

TP = TDWP+TAWP+TUBP;

%Potential
VDWP = 0;
VAWP = mw*g*(rk+rw)*cos(omg(t));
VUBP = mu*g*L*cos(omg(t));

VP = VDWP+VAWP+VUBP;

LP = TL-VL;

QP = [rk/rw*tau(t), -rk/rw*tau(t)];
%Q about  phi, omega

dLPdphi = diff(LP,dphi);
dLPphi = diff(LP,phi(t));
dLPdomg = diff(LP,dtheta);
dLPomg = diff(LP,omg(t));

eqn1P = diff(dLPdphi)-dLPphi == QP(1);
eqn2P = diff(dLPdomg)-dLPomg == QP(2);

disp('Planetary Rail Eqn #1')
pretty(simplify(eqn1P))
disp('Planetary Rail Eqn #2')
pretty(simplify(eqn2P))
