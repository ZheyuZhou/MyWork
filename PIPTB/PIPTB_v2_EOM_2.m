syms phi dphi psi dpsi omg domg mk mw mu rk rw L D tau
%phi Driven Wheel | psi Actuating Wheel | omg Upper Body

g = 9.81;

IU = mu * L^2;
IW = 1/2 * mw * rw^2;
IK = 1/2 * mk * rk^2;

%dphi = diff(phi(t),t);
%dpsi = diff(psi(t),t);
%domg = diff(omg(t),t);

%Linear Rail

%Kinetic
TDWL = 1/2*mk*(rk*dphi)^2 + 1/2*IK*dphi^2;
TAWL = 1/2*mw*((rk*dphi)^2 + 2*(rk+rw)*cos(omg)*domg*(rk*dphi) + (rk+rw)^2*domg^2) + 1/2*IW*(rk/rw*(dphi-domg)-domg)^2;
TUBL = 1/2*mu*((rk*dphi)^2 + 2*L*cos(omg)*domg*(rk*dphi) + L^2*domg^2) + 1/2*IU*(domg)^2;

TL = TDWL+TAWL+TUBL;

%Potential
VDWL = 0;
VAWL = mw*g*(rk+rw)*cos(omg);
VUBL = mu*g*L*cos(omg);

VL = VDWL+VAWL+VUBL;

LL = TL-VL;

QL = [rk/rw*tau, -rk/rw*tau];
%Q about  phi, omega

dLLdphi = diff(LL,dphi);
dLLphi = diff(LL,phi);
dLLdomg = diff(LL,domg);
dLLomg = diff(LL,omg);

eqn1L = diff(dLLdphi)-dLLphi == QL(1);
eqn2L = diff(dLLdomg)-dLLomg == QL(2);
eqnsL = [eqn1L, eqn2L];

%Planetary Rail

%Kinetic
TDWP = 1/2*mk*(rk*dphi)^2 + 1/2*IK*dphi^2 + 1/2*mk*(dphi*rk/D)^2;
TAWP = 1/2*mw*((rk*dphi)^2 + 2*(rk+rw)*cos(omg)*domg*(rk*dphi) + (rk+rw)^2*domg^2) + 1/2*IW*(rk/rw*(dphi-domg)-domg)^2 + 1/2*mw*(dphi*rk/D)^2;
TUBP = 1/2*mu*((rk*dphi)^2 + 2*L*cos(omg)*domg*(rk*dphi) + L^2*domg^2) + 1/2*IU*(domg)^2 + 1/2*mu*(dphi*rk/D)^2;

TP = TDWP+TAWP+TUBP;

%Potential
VDWP = 0;
VAWP = mw*g*(rk+rw)*cos(omg);
VUBP = mu*g*L*cos(omg);

VP = VDWP+VAWP+VUBP;

LP = TL-VL;

QP = [rk/rw*tau, -rk/rw*tau];
%Q about  phi, omega

dLPdphi = diff(LP,dphi);
dLPphi = diff(LP,phi);
dLPdomg = diff(LP,domg);
dLPomg = diff(LP,omg);

eqn1P = diff(dLPdphi,t)-dLPphi == QP(1);
eqn2P = diff(dLPdomg,t)-dLPomg == QP(2);