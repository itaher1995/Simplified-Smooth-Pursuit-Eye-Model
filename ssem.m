function ssem = ssem(T_dot,E_dot,t_Iteration,alpha)

%% Simulation of Simplified Smooth Pursuit System with DYNAMIC GAIN. 
E_dot_array=zeros(1,t_Iteration);
retinal_Slip_array=zeros(1,t_Iteration);
correction_array=zeros(1,t_Iteration);
position_array=zeros(1,t_Iteration);
position=0;
t_Position=0;
t_Position_array=zeros(1,t_Iteration);
G_array = zeros(1,t_Iteration);
PE_array=zeros(1,t_Iteration);
tXE_array=zeros(1,t_Iteration);
j=0;
cus = 0;
for i=1:t_Iteration%t_Iteration = total number of iterations
    retinal_Slip=T_dot-E_dot;%retinal slip velocity (error) = Target Velocity - Eye Velocity
    retinal_Slip_array(i)=retinal_Slip;
    position_Error=t_Position-position;%positional error
    PE_array(i)=position_Error;
    sigmoid=tanh(alpha.*retinal_Slip)./1000;%hyperbolic tangent function 
    G=E_dot./T_dot;%Closed Loop Gain
    G_array(i)=G;
    k=(1-G)./G;%Gain Factor
    correction=sigmoid.*k;%correction added to E_dot
    correction_array(i)=correction;
    t_XE=-position_Error./retinal_Slip;%eye crossing time
    tXE_array(i)=t_XE;
    E_dot=E_dot+correction;%new eye velocity = old eye velocity + correction
    E_dot_array(i)=E_dot;
    t_Position=t_Position+T_dot; %changed the position based on velocity
    t_Position_array(i)=t_Position;
    if (cus == 1)%if bool_flag is true
        j = j+1;%increment catch up saccade timer
    %if both target position and eye position are greater than 0 AND
    %tXE<.04s or tXE>.18s catch-up saccade occurs
    elseif (gt(position,0)&&gt(t_Position,0))&&(lt(tXE_array(i),40) || gt(tXE_array(i),180) && cus == 0) 
        cus=1;
    end
    
    if (j==100 && cus == 1)%if minimum latency is met and catch up saccade was initiated
        position = t_Position;
        cus = 0;
        j = 0;
    else
        position = position + E_dot; %do as normal.
    end    
    position_array(i)=position;
end
ts=1:t_Iteration;

subplot(3,3,3)
plot(ts,correction_array)
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Correction (deg/ms)') % y-axis label

subplot(3,3,1)
plot(ts,position_array)
hold on
plot(ts,t_Position_array)
hold off
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Position (deg)') % y-axis label
legend({'Eye Postion','Target Position'})

subplot(3,3,2)
plot(ts,E_dot_array)
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Eye Velocity (deg/ms)') % y-axis label

subplot(3,3,5)
plot(ts,retinal_Slip_array)
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Retinal Slip (deg/ms)') % y-axis label

subplot(3,3,4)
plot(ts,PE_array)
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Positional Error(deg)') % y-axis label

subplot(3,3,6)
plot(ts,tXE_array)
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Eye Crossing Time(ms)') % y-axis label

subplot(3,3,7)
plot(ts,G_array)
xlabel('Time Stamp (ms)') % x-axis label
ylabel('Gain') % y-axis label
