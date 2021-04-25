syms psi phi theta tau mk mw mu rk rw L D dpsi dphi dtheta g
%psi Driven Wheel | phi Actuating Wheel | theta Upper Body
assume([mk mw mu rk rw L D g],'positive')
assume([psi phi theta tau dpsi dphi dtheta],'real')

%g = 9.81;

IU = mu * L^2;
IW = 1/2 * mw * rw^2;
IK = 1/2 * mk * rk^2;

%Linear Rail

%Kinetic
TDWL = 1/2*mk*(rk*dpsi)^2 + 1/2*IK*dpsi^2;
TAWL = 1/2*mw*((rk*dpsi)^2 + 2*(rk+rw)*cos(theta)*dtheta*(rk*dpsi) + (rk+rw)^2*dtheta^2) + 1/2*IW*(rk/rw*(dpsi-dtheta)-dtheta)^2;
TUBL = 1/2*mu*((rk*dpsi)^2 + 2*L*cos(theta)*dtheta*(rk*dpsi) + L^2*dtheta^2) + 1/2*IU*(dtheta)^2;

TL = TDWL+TAWL+TUBL;

%Potential
VDWL = 0;
VAWL = mw*g*(rk+rw)*cos(theta);
VUBL = mu*g*L*cos(theta);

VL = VDWL+VAWL+VUBL;

%Lagragian
LL = TL-VL;

QL = [rk/rw*tau, -rk/rw*tau];
%Q about  phi, theta

dLLdphi = diff(LL,dphi);
dLLphi = diff(LL,phi);
dLLdtheta = diff(LL,dtheta);
dLLtheta = diff(LL,theta);

eqn1L = diff(dLLdphi)-dLLphi == QL(1);
eqn2L = diff(dLLdtheta)-dLLtheta == QL(2);

disp('Linear Rail Eqn #1')
pretty(simplify(eqn1L))
disp('Linear Rail Eqn #2')
pretty(simplify(eqn2L))

