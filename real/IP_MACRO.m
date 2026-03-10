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

% --- Ação Integral ---
% O estado a controlar é alpha (assumindo ser o primeiro estado, x(1))
C_alpha = [1 0 0 0 0];

% Matrizes Aumentadas para LQR
A_aug = [A, zeros(5,1); -C_alpha, 0];
B_aug = [B; 0];


% Regulator parameters
Qi = 50;
Qr_aug = diag([10, 0, 1, 0, 0, Qi]);
Rr_aug = 0.1; % Weight for the input variable

% Novo Ganho LQR
K_aug = lqr(A_aug, B_aug, Qr_aug, Rr_aug);

% Separar os ganhos para o Simulink
K_x = K_aug(1:5);      % Ganho dos estados originais
K_i = K_aug(6);        % Ganho da ação integral

% Estimator parameters
G = eye(size(A)); %
Qe = eye(size(A))*10; %Variance of process errors
Re = eye(2); %Variance of measurement errors
L = lqe(A, G, C, Qe, Re); %Calculate estimator gains