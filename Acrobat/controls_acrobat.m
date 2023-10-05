% Physics Setup
l = 100/1000; % m
g = 9.81;
freq = 5/1000; % ms

% Initial States
theta = 0.02;
theta2 = pi/2;
w = 0;
w2 = 0;

% Targets
thetaR = 0;
theta2R = pi/2;

% Ranges
theta2Min = pi/6;
theta2Max = 11*pi/6;
aMax = 40;

% Equations Of Motion
syms theta0 theta20
aG(theta0, theta20) = g*sin(theta0)/(2*l*sin(theta20/2));
a2G(theta0, theta20) = g*sin(theta0+theta20/2-pi/2)/l;

% Control System
A(theta0, theta20) = [0                1 0                -1/2; ...
                      diff(aG,theta0)  0 diff(aG,theta20)  0; ...
                      0                0 0                 1; ... 
                      diff(a2G,theta0) 0 diff(a2G,theta20) 0];
B = [0 0 0 1]';
R = [thetaR 0 theta2R 0]';
C = [1 0 0 0; 0 0 1 0];
D = [0 0]';

% C2 = g*cos(theta_1_goal)/(2*l*sin(theta2/2));
% C3 = g*sin(theta_1_goal)*cos(theta2/2)/(4*l*(sin(theta2/2)^2));
% C4 = g*sin(pi/2-theta2R-theta_1_goal)/l;
% C5 = -g*cos(pi/2-theta2R-theta_1_goal)/l;
% C6 = -g*cos(pi/2-theta2R-theta_1_goal)/(2*l);

% A = [0  1 0  -1/2; ...
%      C1 0 C2 0; ...
%      0  0 0  1; ... 
%      C3 0 C4 0];
%F = [0 C1-C2*theta-C3*theta_2 0 0]'; %- dF;
%F = [0 C1 0 0]'; %- dF;
poles = [-2+10*1i -2-10*1i -1.6+1.3*1i -1.6-1.3*1i];
%eig = [-7+7i -7-7i -12+12i -12-12i];
% K = acker(A, B, poles);
%L = place(A',C', eig)';
%K_log = [0 0 0];

% Transfer Functions
s = tf('s');
Kp = 1;
Ki = 0.5;
Kd = 0.5;
PID = Kp + Ki/s + Kd*s;

% Initial States
theta = [theta 0 0 0];
theta2 = [theta2 0 0 0];
w = [w 0 0 0];
w2 = [w2 0 0 0];
%w_est = [0 0 0];
%w_2_est = [0 0 0];
a = [0 0 0 0];
a2 = [0 0 0 0];
aM = [0 0 0 0];
%err = [0 0 0; 0 0 0; 0 0 0; 0 0 0];
err = [0 0 0 0];

%state_fb = [0 0 0 0]';
%input_fb = [0 0 0 0]';
%x_est = [0 0 0 0]';
%y_est = [0 0]';

% Initial Figure
f = figure();
xlim((2.1*l)*[-1 1]);
ylim((2.1*l)*[-1 1]);
theta1 = get_theta1(theta(1), theta2(1));
theta1R = get_theta1(thetaR, theta2R);
[x1,y1,x2,y2] = coords(l,theta1,theta2(1));
[xR1,yR1,xR2,yR2] = coords(l,theta1R,theta2R);
hold on
l1 = plot([0 x1],[0 y1],'linewidth',2);
l2 = plot([x1 x2],[y1 y2],'linewidth',2);
ball = plot(x2,y2,'.','MarkerSize',40);
goal1 = plot(xR1,yR1,'.','MarkerSize',20);
goal2 = plot(xR2,yR2,'.','MarkerSize',20);
pause(1)

i = 0;
while (true)
    %theta_2_goal = -pi/4*sin(i*freq/5000000000)+pi/2;
    %theta_goal = get_theta(theta_1_goal, theta_2_goal);
    %R = [theta_goal 0 theta_2_goal 0]';

    % Update Physics
    a2 = shift(a2, aM(1) + double(a2G(theta(1), theta2(1))));
    a = shift(a, a2(1)/2 + double(aG(theta(1), theta2(1))));
    if (w ~= 0)
        a(1) = a(1) - abs(w(1))/w(1) *0.05*g/(2*l);
    end
    if (w2 ~= 0)
        a2(1) = a2(1) - abs(w2(1))/w2(1) *0.05*g/l;
    end
    
    theta = z_transfer(theta, [w; a], [1/s; 1/s^2], freq);
    theta2 = z_transfer(theta2, [w2; a2], [1/s; 1/s^2], freq);
    theta2(1) = max(theta2Min,min(theta2Max,theta2(1)));

    %theta = z_transfer(theta, w, 1/s, freq);
%     theta(1) = mod(theta(1), 2*pi);
% 
%     theta_2 = z_transfer(theta_2, [w_2; a_2], [1/s; 1/s^2], freq);

   %w = z_transfer(w, a, 1/s, freq);
%     w_2 = z_transfer(w_2, a_2, 1/s, freq);

    %theta = theta + w(1)*freq + a(1)*freq^2/2; %shift(theta, mod(theta(1) + w(1)*freq + a(1)*freq^2/2, 2*pi));
    %theta2 = theta2 + w2(1)*freq + a2(1)*freq^2/2; %shift(theta_2, mod(theta_2(1) + w_2(1)*freq + a_2(1)*freq^2/2, 2*pi));
    %theta_2(1) = max(theta_2_min,min(theta_2_max,theta_2(1)));

    
    w = z_transfer(w, a, 1/s, freq);
    w2 = z_transfer(w2, a2, 1/s, freq);
    %w = shift(w, w(1) + a(1)*freq); %shift(w, w(1) + a(1)*freq);
    %w2 = shift(w2, w2(1) + a2(1)*freq); %shift(w_2, w_2(1) + a_2(1)*freq);
    
    % Update Controls System
%     C1 = g*sin(theta(2)-theta_2(2)/2)/(2*l*sin(theta_2(2)/2));
%     C2 = g*cos(theta(2)-theta_2(2)/2)/(2*l*sin(theta_2(2)/2));
%     C3 = g*sin(theta(2))/(2*l*(cos(theta_2(2)/2)-1));
% 
%     A = [0 1 0 0; C2 0 C3 0; 0 0 0 1; 0 0 0 0];
%     % F = [0 0 C1-C2*theta(2)-C3*theta_2(2) 0]';
%     F = [0 0 C1 0]';
%     poles = [-2+10*1i -2-10*1i -1.6+1.3*1i -1.6-1.3*1i];
%     eig = [-7+7i -7-7i -12+12i -12-12i];
%     K = acker(A, B, poles);
%     L = place(A',C', eig)';

    % Observer
%     new_theta_1 = get_theta_1(theta(1), theta_2(1));
%     % err_fb = L*[dist(theta(1),y_est(1)) dist(theta_2(1),y_est(2))]';
%     err_fb = L*[dist(new_theta_1,y_est(1)) dist(theta_2(1),y_est(2))]';
%     x_est = x_est + freq*(state_fb+input_fb+err_fb);% + dF; %%% integral
%     x_est(1) = mod(x_est(1), 2*pi);
%     x_est(3) = mod(x_est(3), 2*pi);
%     state_fb = A*x_est;
%     y_est = C*x_est;
%     % err_est = [diff(R(1),x_est(1)) R(2)-x_est(2) diff(R(3),x_est(3)) R(4)-x_est(4)]';
%     % a_2 = K*err_est;
%     a_2 = K*(R - x_est);
%     a_2 = max(-max_a,min(max_a,a_2));
%     input_fb = B*a_2;
%     fprintf("theta: %.2f, theta2: %.2f\nest:   %.2f, est:    %.2f\ngoal:  %.2f, goal:   %.2f\na_2: %.3f\n\n", mod([theta theta_2 y_est(1) y_est(2) theta_goal theta_2_goal],2*pi),a_2);

    % Derviative Feedback
%     Ak = A - B*K;
%     [num, den] = ss2tf(Ak, B*K, C, zeros(1,4), 1);
%     G = tf(num(1,:), den);
%     G2 = tf(num(2,:), den);
%     a_2 = K*[dist(R(1),theta) R(2)-w dist(R(3),theta_2) R(4)-w_2]';

%     sys = ss(A,B,[0 0 1 0],0);
%     K = pid(sys);

    % w_est = z_transfer(w, theta, s, freq);
    % w_2_est = z_transfer(w, theta, s, freq);
    
%     old_theta_1 = get_theta_1(theta(2), theta_2(2));
%     old_w_1 = w(2) - w_2(2);
%     state_est = [new_theta_1 new_w_1 theta2 w_2]'; %- [pi/2 0 pi/2 0]'%- [old_theta_1 old_w_1 theta_2(2) w_2(2)]'
%     err = shift(err, K*(R-state_est));
    % err = shift(err, dist(get_theta_1(R(1), R(3)), get_theta_1(theta(1), theta_2(1))));
    %a_2 = z_transfer(a_2, a, -0.5*PID, freq);
    % a_2 = z_transfer(a_2, err, PID, freq);

    %K_log = shift(K_log, K*err(:,1));
    %a_2 = K*err(:,1); %+ F(2);
    
    %theta_1_log = shift(theta_1_log, theta_1);
    %a_2 = -2*C2*theta_1;
    % a_2_log = z_transfer(a_2_log, K_log, PID, freq);
    %a_2 = max(-max_a,min(max_a,a_2));

    i = i + 1;
    if (mod(i, cast(1/100 / freq,"uint8")) == 0)
        % Edit Figure
        theta1 = get_theta1(theta(1), theta2(1));
        [x1,y1,x2,y2] = coords(l,theta1,theta2(1));
        [xR1,yR1,xR2,yR2] = coords(l,theta1R,theta2R);
        set(l1,'XData',[0 x1],'YData',[0 y1]);
        set(l2,'XData',[x1 x2],'YData',[y1 y2]);
        set(ball,'XData',x2,'YData',y2);
        set(goal2,'XData',xR2,'YData',yR2);
        set(goal1,'XData',xR1,'YData',yR1);
    end
    pause(freq)
end

function [x1,y1,x2,y2] = coords(l,theta,theta_2)
    x1 = l*cos(theta+pi/2);
    y1 = l*sin(theta+pi/2);
    x2 = x1 + l*cos(theta+theta_2+3*pi/2);
    y2 = y1 + l*sin(theta+theta_2+3*pi/2);
end

function ang = dist(theta, theta_2)
    ang = mod(theta-theta_2, 2*pi);
    if (ang > mod(theta_2-theta, 2*pi))
        ang = -mod(theta_2-theta, 2*pi);
    end
end

function y = z_transfer(y, u, tf, freq)
    y_new = y(1);
    y = shift(y, y_new);
    for i=1:length(tf)
        [z_u, z_y] = tfdata(c2d(tf(i), freq, 'tustin'));
        z_u = cell2mat(z_u);
        z_y = cell2mat(z_y);
    
        y_new = y_new - y(1) + sum(z_u.*u(i,1:length(z_u))) - sum(z_y(2:end).*y(1:length(z_y)-1));
    end
    y = shift(y, y_new);
end

function y = shift(y, x)
    y = [x y(:,1:end-1)];
end

function theta1 = get_theta1(theta, theta2)
    theta1 = theta + pi/2 - theta2/2;
end

function theta = get_theta(theta1, theta2)
    theta = theta1 - pi/2 + theta2/2;
end