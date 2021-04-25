clear all

%% system parameters
% mass of each component
mk = 3.6;                  % ball, kg
mw = 3;                  % all three wheels, kg
ma = 75;                % upper body, kg

% geometry of each component
rk = 0.11;              % ball radius, m
rw = 0.05;              % wheel radius, m
ra = 0.3;               % upper body radius, m

% distance between ball COM to upper body COM
l = 0.5;                % m

% design choice
i = 26;                 % gear reduction
alpha = 45/180*pi;      % omniwheel angle wrt vertical plane, deg 

% inertia properties
Jm = 3.33e-6;                                       % motor rotor inertia, kg*m^2
Jm_reflected = Jm*i^2;                              % reflected motor rotor inertia, kg*m^2
Jw = 900e-6;                                        % each omni wheel inertia, kg*m^2 // can be further divided into wheel radius and weight
Jw_effective = 3/2*cos(alpha)^2*(Jw+Jm_reflected);
Jk = 1/2*mk*rk^2;                                   % ball inertia, kg*m^2
Ja = 1/4*ma*ra^2+1/12*ma*(2*l)^2+ma*l^2;            % upper body inertia, kg*m^2

%% dynamic model
[A,B,C,D] = dynamic_model_2D(mk, mw, ma, rk, rw, ra, l, Jw, Jk, Ja);
 
%% controller 
states = { 'theta' 'theta_dot' 'phi' 'phi_dot'};
inputs = {'u'};
outputs = {'theta' 'theta_dot' 'phi' 'phi_dot'};

% form state space model
sys_ss = ss(A,B,C,D,'statename',states,'inputname',inputs,'outputname',outputs);

% check open-loop poles 
poles = eig(A);

% check controllability
co = ctrb(sys_ss);
controllability = rank(co);

% define LQR controller
p = 2; %weighting factor
Q = p * C'*C;
R = 1;
K = lqr(A,B,Q,R);
Cn = [1 1 1 1];
sys_ss = ss(A,B,Cn,0);
Nbar = rscale(sys_ss,K);

% form close-loop system
Ac = [(A-B*K)];
Bc = [B];
Bc = [B*Nbar];
Cc = [C];
Dc = [D];

sys_cl = ss(Ac,Bc,Cc,Dc,'statename',states,'inputname',inputs,'outputname',outputs);

%% simulation results
% discrete time step
n = 100000; % 5 sec
T = zeros(n,1);
T(1,1)=0;
dt = 0.0001;

% initialize states and estimated states
x1 = zeros(n,1);
x2 = zeros(n,1);
x3 = zeros(n,1);
x4 = zeros(n,1);

dxdt = zeros(4,1);

% state initial conditions
x1(1,1) = 20/180*pi;            % upper body angle (rad), 20deg
x2(1,1) = 0;                    % upper body angular velocity (rad/s)
x3(1,1) = 0;                    % ball angle (rad)
x4(1,1) = 0;                    % upper body angular velocity (rad/s)

% stack states into vectors
x = [x1 x2 x3 x4];
r = [0 0 0 0];
U = zeros(n,1);
for i = 2:n
    
    t = dt*(i-1);
    T(i,1) = t;
    
    u = -K*(x(i-1,:)'-r');
    U(i-1) = u;
    
    dxdt = A*x(i-1,:)'+B*u;
    x(i,:) = x(i-1,:)+dt*dxdt';
end

figure(1)
subplot(5,1,1)
plot(T,x(:,1)*180/pi,'b')
str = {'$$ \theta(\deg) $$'}
ylabel(str,'Interpreter','latex','FontSize',20);
set(gca,'FontSize',20)

subplot(5,1,2)
plot(T,x(:,2)*180/pi,'b')
str = {'$$ \dot{\theta}(\deg/s) $$'};
ylabel(str,'Interpreter','latex','FontSize',20);
set(gca,'FontSize',20)

subplot(5,1,3)
plot(T,x(:,3)*180/pi,'b')
str = {'$$ \phi(\deg) $$'};
ylabel(str,'Interpreter','latex','FontSize',20);
set(gca,'FontSize',20)

subplot(5,1,4)
plot(T,x(:,4)*180/pi,'b')
str = {'$$ \dot{\phi}(\deg/s) $$'};
ylabel(str,'Interpreter','latex','FontSize',20);
set(gca,'FontSize',20)

subplot(5,1,5)
plot(T,U,'b')
xlabel('Time(t)','FontSize',20);
str = {'$$ u(Nm) $$'};
ylabel(str,'Interpreter','latex','FontSize',20);
set(gca,'FontSize',20)

