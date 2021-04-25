function [A,B] = PIPTBStateSpace(p)
% [energy, potential, kinetic] = cartPoleEnergy(z,p)
%
% This function computes the mechanical energy of the cart-pole.
%
% INPUTS:
%   z = [4, n] = [x;q;dx;dq] = state of the system
%   p = parameter struct
%       .g = gravity
%       .m1 = cart mass
%       .m2 = pole mass
%       .l = pendulum length
% OUTPUTS:
%   energy = total mechanical energy
%   potential = potential energy
%   kinetic = kinetic energy
uw=0;
q=0;
dq=0;
[A, B] = autoGen_PIPTBStateSpace(q,dq,uw,p.mK,p.IK,p.rK,p.mA,p.IA,p.lAC,p.mL,p.g);

end