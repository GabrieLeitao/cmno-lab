function create_video(t, alpha, beta, filename)
% CREATE_VIDEO Animate a rotary inverted pendulum in 3D and save as video
%
% INPUTS:
%   t        - time vector from simulation
%   alpha    - arm angle [rad] vector
%   beta     - pendulum angle [rad] vector
%   filename - video filename (e.g., 'IP_3D.avi')
%   folder   - folder path to save video (optional)

% --- Set defaults ---

if nargin < 4 || isempty(filename)
    filename = 'IP_3D.avi';
end

% --- Folder is the same folder as this function ---
folder = fileparts(mfilename('fullpath'));  

% Optional: create subfolder inside function folder
folder = fullfile(folder, 'video-result');
if ~exist(folder,'dir')
    mkdir(folder);
end

fullpath = fullfile(folder, filename);

% --- Video parameters ---
fps = 30;                     % frames per second for video
Tvideo = t(end);              % total simulation time
Nframes = ceil(Tvideo * fps); % number of video frames

% Interpolate signals to match video frames
frame_t     = linspace(0, Tvideo, Nframes);
alpha_frames = interp1(t, alpha, frame_t);
beta_frames  = interp1(t, beta, frame_t);

% --- Pendulum parameters ---
armLength  = 0.216;  % meters
pendLength = 0.337;  % meters

% --- Create video object ---
v = VideoWriter(fullpath);
v.FrameRate = fps;
open(v);

% --- Create single figure ---
fig = figure('Name','Rotary Inverted Pendulum 3D','NumberTitle','off');
axis equal
grid on
xlim([-0.5 0.5]); ylim([-0.5 0.5]); zlim([-0.5 0.5]);
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
view(45,30);  % fixed camera angle
hold on;

% --- Animate pendulum ---
for k = 1:Nframes
    cla(fig);  % clear figure but keep same window

    % Arm end coordinates
    x_arm = armLength * cos(alpha_frames(k));
    y_arm = armLength * sin(alpha_frames(k));
    z_arm = 0;

    % Pendulum tip coordinates
    x_pend = x_arm + pendLength * sin(beta_frames(k)) * cos(alpha_frames(k));
    y_pend = y_arm + pendLength * sin(beta_frames(k)) * sin(alpha_frames(k));
    z_pend = pendLength * cos(beta_frames(k));

    % Draw arm
    plot3([0 x_arm], [0 y_arm], [0 z_arm], 'r', 'LineWidth',3); hold on;

    % Draw pendulum
    plot3([x_arm x_pend], [y_arm y_pend], [z_arm z_pend], 'b', 'LineWidth',3);

    % Draw pivots
    plot3(0,0,0,'ko','MarkerFaceColor','k');
    plot3(x_pend,y_pend,z_pend,'ko','MarkerFaceColor','k');

    % Optional: title with current time
    title(sprintf('Time: %.2f s', frame_t(k)));

    % Capture frame
    frame = getframe(fig);
    writeVideo(v, frame);
end

close(v);
disp(['Video saved to: ' fullpath]);
end