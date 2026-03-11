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

T = 12; % Time duration of the simulation
Ts = 0.001; % Sampling time

% Regulator parameters
Qr = diag([10,1,5,1,0]); %Weight Matrix for x
Rr = 0.1; %Weight for the input variable
K = lqr(A, B, Qr, Rr); %Calculate feedback gain

% Estimator parameters
G = eye(size(A)); %
Qe = eye(size(A))*10; %Variance of process errors
Re = eye(2); %Variance of measurement errors
L = lqe(A, G, C, Qe, Re); %Calculate estimator gains


% Solve the continuous-time algebraic Riccati equation for estimator
Pe = care(A', C', Qe, Re);  % Note transpose of A and C
J_estimator = trace(Pe);  % Scalar measure of overall estimation error

% Furuta pendulum - State feedback test 
%---------------------------------------------------------------------- 
% Simulate controller 
x0=[0.1 0.5 0.2 0 0]; 
D=[0 0]';

% Sim parameters
saturation = 5; % -5 to 5
tau = 0.02; % Motor lag: 0.02 - 0.1s
dead_zone = 0.1; % Dead zone half-width

%b_alpha = 0.001; % Viscous friction for alpha: 0.001 - 0.01 
%b_beta = 0.0005; % Viscous friction for beta: 0.0005 - 0.005 
%tau_c = 0.01; % Coulomb friction: 0.01 - 0.05 N.m

noise_power = 1e-5; % White noise power
noise_sample_time = 0.01; % s
quant = 2 * pi / 4096; % quantizer interval in output

sim('LQG.slx',T);
gg=plot(t.Time,y.Data(:,2));
set(gg,'LineWidth',1.5) 
gg=xlabel('Time (s)');
set(gg,'Fontsize',14);
gg=ylabel('\beta (rad)');
set(gg,'Fontsize',14); 


% Extract time and signals
t     = y.Time;         % time vector
alpha = y.Data(:,1);    % alpha signal
beta  = y.Data(:,2);    % beta signal

MSE_alpha = (1/T) * trapz(t, alpha.^2);
MSE_beta = (1/T) * trapz(t, beta.^2);
Energy = trapz(t, u.Data(:,1).^2);

fprintf("MSE_alpha: %g\n", MSE_alpha);
fprintf("MSE_beta: %g\n", MSE_beta);
fprintf("Energy: %g\n", Energy);

%% Display results
disp('Computed Rr:'), disp(Rr)
disp('Feedback gain K:'), disp(K)

% Call video function
addpath(pwd, 'SimulationVideo')
create_video(t, alpha, beta);
%---------------------------------------------------------------------- 
% End of file 