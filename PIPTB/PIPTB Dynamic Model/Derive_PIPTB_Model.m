% Derive_PIPTB_Model.m
% This script derives the equations of motion for a simple self-balancing
% robot
clear; clc;
%% deriving euqation of motion for human-PURE-model
% generalized cooridnates (theta: lower bdoy, phi: wheel, zeta: upper body)
syms theta phi dtheta dphi ddtheta ddphi 'real'
q = [theta, phi].';
dq = [dtheta, dphi].';
ddq = [ddtheta, ddphi].';
% assuming rider has no DOF
zeta = 0;dzeta = 0;
% generalized force
syms uw 'real'
% physical parameters for wheel
syms mK rK IK 'real'
% physical parameters for slider
syms mL fL 'real'
% physical parameters for upper body
syms lAC mA IA 'real'
% other parameters
syms g 'real'
% Energyies
% Wheel
TK = 1/2*mK*(rK*dphi)^2+1/2*IK*dphi^2;
VK = 0;
% Body
vA = [rK*dphi+lAC*cos(theta)*dtheta;0;-lAC*sin(theta)*dtheta];
TA = 1/2*mA*(vA'*vA)+1/2*IA*dtheta^2;
VA = mA*g*lAC*cos(theta);
% Slider
TL = 1/2*mL*(rK*dphi)^2;
%fNP = [-rK/rW*uw; rK/rW*uw];
JNP = [-1;1];
% Equation of motion
T = TK+TA+TL; V = VK+VA;
L = T-V;
x = [theta phi dtheta dphi];
dx = [dtheta dphi ddtheta ddphi];
% EOM 1
pLpdtheta = diff(L, dtheta);
ddtpLpdtheta = jacobian(pLpdtheta,x)*dx.';
pLptheta = diff(L, theta);
% EOM 2
pLpdphi = diff(L, dphi);
ddtpLpdphi = jacobian(pLpdphi,x)*dx.';
pLpphi = diff(L, phi);
%% nonlinear system model
eqth1 = simplify(ddtpLpdtheta - pLptheta);
eqth2 = simplify(ddtpLpdphi - pLpphi);
E = [eqth1;eqth2];
M = jacobian(E,ddq);
CG = simplify(E - M*ddq);
u = uw;
dyn = simplify(M\(JNP*u-CG));
ddtheta_solv=simplify(dyn(1));
ddphi_solv=simplify(dyn(2));
%% linearized system model * state space
% equilibirium point
qeq=zeros(2,1);
dqeq=zeros(2,1);
% linearization using taylor expansion
E_val = eval(E); % evaluate left side of equation of motion
EL = taylor(E_val,x,[qeq;dqeq],'Order',2); %linearization using taylor expansion
% EL = ML*ddq+CL*dq+GL*q
ML = simplify(jacobian(EL,ddq)); % calculate ML
CGL = simplify(EL-ML*ddq);
CL = jacobian(CGL,dq);
GL = jacobian(CGL,q);
simplify(EL-ML*ddq-CL*dq-GL*q) %check equivalence
A11 = zeros(2,2);
A12 = eye(2,2);
A21 = -ML\GL;
A22 = -ML\CL;
A = [A11,A12;A21,A22];
B1 = zeros(2,1);
B2 = ML\JNP;
B = [B1;B2];
C = eye(4,4);
D = zeros(4,1);
%D = zeros(6,2);
%rank(ctrb(A,B))
%% File generation
%%%% Generate an optimized matlab function for dynamics:
matlabFunction(dyn(1),dyn(2),...
    'file','autoGen_PIPTBDynamics.m',...
    'vars',{q,dq,uw,mK,IK,rK,mA,IA,lAC,mL,g},...
    'outputs',{'ddtheta','ddphi'});

%%%% Generate an optimized matlab function for state space model:
matlabFunction(A,B,...
    'file','autoGen_PIPTBStateSpace.m',...
    'vars',{q,dq,uw,mK,IK,rK,mA,IA,lAC,mL,g},...
    'outputs',{'A','B'});

%%%% Generate a matlab function for energy:
matlabFunction(V,T,...
    'file','autoGen_PIPTBEnergy.m',...
    'vars',{q,dq,uw,mK,IK,rK,mA,IA,lAC,mL,g},...
    'outputs',{'V','T'});

% %%%% Generate a function for computing the kinematics:
% syms empty 'real'  %fixes a bug in matlabFunction related to vectorization
% % pK(2) = pK(2) + empty;
% % vK(2) = vK(2) + empty;
% matlabFunction(pK,pAC,vK,vAC,...
%     'file','autoGen_SBRKinematics.m',...
%     'vars',{q,dq,mK,IK,rK,mA,IA,lAC,g,empty},...
%     'outputs',{'pK','pAC','dpK','dpAC'});

