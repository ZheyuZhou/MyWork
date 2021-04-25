function dx = PIPTBDynamics(x,uw,p)

theta = x(1,:);  
phi = x(2,:);
dtheta = x(3,:);
dphi = x(4,:);
q = [theta;phi];
dq = [dtheta;dphi];

[ddtheta,ddphi] = autoGen_PIPTBDynamics(q,dq,uw,p.mK,p.IK,p.rK,p.mA,p.IA,p.lAC,p.mL,p.g);

dx = [dtheta;dphi;ddtheta;ddphi];

end