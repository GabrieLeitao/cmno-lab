% ------------------------------
% CMNO 2025/2026 - Gabriel Faria, Gabriel Leitão, Rodrigo Boulhosa
% ------------------------------

% Load state model
load('IP_MODEL.mat')

% Constraints
V_MAX = 5; % Maximum motor voltage
V_MIN = -5; % Minimum motor voltage

ALPHA_MAX = 90 * pi/180; % Maximum angle accepted for motor shaft
BETA_MAX = 15 * pi/180; % Maximum angle before falling
TIME_DELAY = 6; % seconds before start

T = 5; % Time duration of the simulation
Ts = 0.001; % Sampling time

% Regulator parameters
Qr = diag([10,0,1,0,0]); %Weight Matrix for x
Rr = 0.1; %Weight for the input variable
K = lqr(A, B, Qr, Rr); %Calculate feedback gain

% Estimator parameters
G = eye(size(A)); %
Qe = eye(size(A))*10; %Variance of process errors
Re = eye(2); %Variance of measurement errors
L = lqe(A, G, C, Qe, Re); %Calculate estimator gains


% Furuta pendulum - State feedback test 
%---------------------------------------------------------------------- 
% Simulate controller 
x0=[0.1 1 0.2 0 0]'; 
D=[0 0]';

D_perturb = [0 0 0 0 0]';
C_perturb = eye(5);
Rep = eye(5);
L_perturb = lqe(A, G, C_perturb, Qe, Rep); %Calculate estimator gains


sim('LQE_perturbed.slx',T); 
gg=plot(t.Time,y.Data(:,2)); 
set(gg,'LineWidth',1.5) 
gg=xlabel('Time (s9'); 
set(gg,'Fontsize',14); 
gg=ylabel('\beta (rad)'); 
set(gg,'Fontsize',14); 


% Extract time and signals
t     = y.Time;         % time vector
alpha = y.Data(:,1);    % alpha signal
beta  = y.Data(:,2);    % beta signal

% Call video function
addpath(pwd, 'SimulationVideo')
create_video(t, alpha, beta);
%---------------------------------------------------------------------- 
% End of file 