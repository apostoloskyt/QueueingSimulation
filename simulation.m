% Queueing Systems 2017-2018
%
% Manolis Katsaragakis 03113059
% Apostolos Kyteas 03113209
%
% M/M/2/8 Simulation with threshold and random activation

clc;
clear all;
close all;

total_arrivals = 0; % to measure the total number of arrivals
current_state = 0;  % holds the current state of the system
previous_mean_clients = 0; % will help in the convergence test
index = 0;

lambda = 6; 
mu_a = 8;
mu_b = 8;
k = 3;
p = 0.5;
b_active = false;
a_active = true;
p1a = zeros([1,6]);
p2a = zeros([1,6]);
p3a = zeros([1,6]);
p1b = zeros([1,6]);
p2ab = zeros([1,6]);
p3ab = zeros([1,6]);
ga = zeros([1,6]);
gb = zeros([1,6]);
logos = zeros([1,6]);

threshold = lambda/(lambda + mu_a*a_active + mu_b*b_active); % the threshold used to calculate probabilities. If both servers are active we double mu.

for k=3:1:6

transitions = 0; % holds the transitions of the simulation in transitions steps
blocked = 0;
 

while transitions >= 0
  transitions = transitions + 1; % one more transition step
  
  if mod(transitions,1000) == 0 % check for convergence every 1000 transitions steps
    index = index + 1;
    for i=1:1:length(arrivals)
        P(i) = arrivals(i)/total_arrivals; % calcuate the probability of every state in the system
        P_blocked = blocked/total_arrivals;
    endfor
    p1a(k) = p1a(k)/total_arrivals;
    p2a(k) = p2a(k)/total_arrivals;
    p3a(k) = p3a(k)/total_arrivals;
    p1b(k) = p1b(k)/total_arrivals;
    p2ab(k) = p2ab(k)/total_arrivals;
    p3ab(k) = p3ab(k)/total_arrivals;
    
    
    mean_clients = 0; % calculate the mean number of clients in the system
    for i=1:1:length(arrivals)
       mean_clients = mean_clients + (i-1).*P(i);
    endfor
    
    to_plot(index) = mean_clients;
        
    if abs(mean_clients - previous_mean_clients) < 0.0000001 || transitions > 1000000 % convergence test
      break;
    endif
    
    previous_mean_clients = mean_clients;
    
  endif
  
  random_number = rand(1); % generate a random number (Uniform distribution)
  threshold = lambda/(lambda + mu_a*a_active + mu_b*b_active); % the threshold used to calculate probabilities. If both servers are active we double mu.
  if current_state == 0 || random_number < threshold % arrival
    total_arrivals = total_arrivals + 1;
    a_active = true;
    try % to catch the exception if variable arrivals(i) is undefined. Required only for systems with finite capacity. In this case our system has a capacity of 8 clients. 
      arrivals(current_state + 1) = arrivals(current_state + 1) + 1; % increase the number of arrivals in the current state
      current_state = current_state + 1;
      if current_state == 1 && b_active == true
        p1b(k) = p1b(k) + 1;
      elseif current_state == 1 && a_active == true
        p1a(k) = p1a(k) + 1;
      elseif current_state == 2 && b_active == false
        p2a(k) = p2a(k) + 1;
      elseif current_state == 2 && b_active == true
        p2ab(k) = p2ab(k) + 1;
      elseif current_state == 3 && b_active == false
        p3a(k) = p3a(k) + 1;
      elseif current_state == 3 && b_active == true
        p3ab(k) = p3ab(k) + 1;
      endif      
        
    catch
      if current_state <8      
        arrivals(current_state + 1) = 1;
        current_state = current_state + 1;
      else
        blocked = blocked+1;
      endif
    end
    if current_state == k && not(b_active)      %random activation of second server with probability 1-p
      b_active = rand(1) > p;
    elseif current_state > k
      b_active = true;
    endif
  else % departure
    if current_state != 0                         % no departure from an empty system
      current_state = current_state - 1;
      if b_active
        if  current_state == 0                  %if no clients remain  then b is set to inactive
          b_active = false;
          a_active = true;
        elseif current_state == 1           %if only one client remains either a or b remains active
          random_number = rand(1);
          a_active = (random_number <= p);
          b_active = (random_number > p);
        elseif current_state <= k           %if  less than or equal to k clients remain in the system then
          random_number = rand(1);
          if random_number < 0.5          %if the client was served by server b then we check if server b should remain active
            if current_state == k              %if  k clients remain in the system then b remains active with probability p or becomes inactive with probability 1-p
              random_number = rand(1);
              b_active = (random_number < p);
            else                                        %if  less than k clients remain in the system then b becomes inactive
              b_active = false;
            endif
          endif
        endif
      endif
    endif
  endif
endwhile

for i=1:1:length(arrivals)
  display(P(i));
endfor
display("P_blocked");
display(P_blocked);

sim_mean(k) = mean_clients;

endfor

#{
figure(1);
plot(to_plot,"r","linewidth",1.3);
title("Average number of clients in the M/M/2/8 queue: Convergence, lambda=8");
xlabel("transitions in thousands");
ylabel("Average number of clients");
#saveas (1,"/home/apostolos/Documents/NTUA/10oExamhno/simulation/2_clients_lambda10.png");

figure(2);
bar(P,'r',0.4);
title("Probabilities, lambda=8");
#saveas (2,"/home/apostolos/Documents/NTUA/10oExamhno/simulation/2_probs_lambda10.png");
#}

for k=3:1:6
  ga(k) = mu_a*(1-p1b(k))
  gb(k) = mu_b*(1-p1a(k)-p2a(k)-p3a(k))
endfor

for k=3:1:6
  logos(k) = ga(k)/gb(k);
endfor

ga
gb
logos
#{
p1a
p2a
p3a
p1b
p2ab
p3ab
#}
sim_mean
figure(3);
bar(sim_mean,"r",0.4);
title("Average number of clients in the M/M/2/8 queue k = 3,4,5,6, lambda=8");
#saveas (3,"/home/apostolos/Documents/NTUA/10oExamhno/simulation/k_means_lambda=6.png");