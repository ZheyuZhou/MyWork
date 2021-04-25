% LQR derivation
clc; clear;
addpath ../../
%% Dynamic simulation of 2D planar model of human-PURE interaction
% model parameters
% physical parameters for wheel
% roter inertia of U10 motor: 0.0001 kgm^2
% physical parameters for wheel
p.rK = 5*0.0254/2; % unit: m
p.mK = 1.29; % unit:kg
%p.mK = p.mK/4;
p.IK = 2310677/1e9+0.0002*7.5^2;% unit: kg*m^2
%p.IK = p.IK/4;
% physical parameters for slider
p.mL = 0.34; % unit: kg
% physical parameters for upper body
p.mA = 5.32; % unit: kg
p.lAC = (120.28)/1000; % unit: m
p.IA = 37160827/1e9;% + p.mA*(p.lAC)^2;% unit: kg*m^2
% other parameters
p.g = 9.8;
param=[ 0 p.mK p.IK p.rK  p.mA p.IA p.lAC p.mL p.g];
%% LQR controller design
[A,B]=PIPTBStateSpace(p);
Q = diag([20 20 10 10]);
R = diag(5);
[K,S,e] = lqrd(A,B,Q,R,0.001);
K = [-26 0 -3.84 -1.136]
[A,B]=PIPTBStateSpace(p);
Q = diag([200 200 10 10]);
R = diag(50);
[K,S,e] = lqrd(A,B,Q,R,0.001);
[A,B]=PIPTBStateSpace(p);
Q = diag([200 200 10 10]);
R = diag(5);
[K,S,e] = lqrd(A,B,Q,R,0.001);
K = [-46.14 0 -7.4 -1.998];
%% initial condition
x0=[0/180*pi; 0; 0; 0];
%% data plotting for experimental result
close all
load('PIPTBtest4processed.mat')
theta = PIPTBtest4.roll-pi/2-0.0336;
dtheta = PIPTBtest4.dyaw;
u = PIPTBtest4.uroll;
dphi = PIPTBtest4.vy;
t0 = 605;
tf = 805;%length(theta);
t = linspace(0,1,tf-t0+1);
figure(1)
plot(t,theta(t0:tf))
hold on

figure(2)
plot(t,dtheta(t0:tf))
hold on
plot(t,dphi(t0:tf))

figure(3)
plot(t,u(t0:tf))
hold on
%% data plotting for simulation results
states = out.states;
command_torque = out.command_torque;
theta_sim = -states(:,2);
dtheta_sim = -states(:,4);
dphi_sim = -states(:,5);
u_sim = -command_torque(:,2);
t0 = 1;
tf = 1000;%length(theta);
t = linspace(0,1,tf-t0+1);
figure(1)
plot(t,theta_sim(t0:tf))
legend('experiment','simulation')
ylabel('Angle (rad)')
xlabel('Time (s)')

figure(2)
plot(t,dtheta_sim(t0:tf))
plot(t,dphi_sim(t0:tf))
legend('tilt angular rate exp','angular velocity exp','tilt angular rate sim','angular velocity sim')
ylabel('Angular rate (rad/s)')
xlabel('Time (s)')

figure(3)
plot(t,u_sim(t0:tf))
legend('experiment','simulation')
ylabel('command torque (Nm)')
xlabel('Time (s)')
