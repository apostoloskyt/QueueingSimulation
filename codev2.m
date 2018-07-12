close all;
clear all;
clc;
k_vector=[3 4 5 6]; %vector of all k values
ma=8;
mb=8;
p=0.9;
    
for l=6:1:8 % loop for all lambdas
  averages_k =[]; 
  ga_k =[]; % throughput of a
  gb_k = []; % throughput of b
   for k=3:1:6 % loop for all k
    state = 0; % initial state = 0
    arrivals_counter = 0;
    total_counter = 0;
    upper_chain = 1;
    conversion_old = 0.0; %about convergence
    conversion_new = 100.0; %about convergence
    arrivals_a = zeros([1,12]);
    arrivals_ab = zeros([1,12]);
    prob_arrival_a = zeros([1,12]);
    prob_arrival_ab = zeros([1,12]);
    averages_vector = [];
    totalcounter_vector =[];
    %--------SIMULATION && PLOTTING -----------------------%
    while (abs(conversion_old - conversion_new) > 0.0000001 && (total_counter <1000000)) %chack convergence
      i = rand(1); %random generator
      if (state==0) %Zero state
        arrivals_counter=arrivals_counter+1;
        arrivals_a(state+1)=arrivals_a(state+1) + 1;
        state=state+1;
        upper_chain=1;
      elseif (state == 8) %Final State(queueing system is full)
        if i < (p*l/(p*l+ma+mb)) %Arrival
          arrivals_counter = arrivals_counter +1;
          arrivals_ab(state+1) = arrivals_ab(state+1) +1;
        else
          state = state -1;
        end
      elseif ((state<k+1) && (upper_chain==1) && (state~=0)) %on state k-1 and a is active
        if (i < p*l/(p*l+ma)) %Arrival
          arrivals_counter = arrivals_counter + 1;
          arrivals_a(state+1)=arrivals_a(state+1) + 1;
          state = state+1;
          if (state == k+1)
            upper_chain=0;
          end
        else %Departure
          state = state -1;
        end
      elseif ((state<=(k+1)) && (upper_chain==0) && (state~=0) && (state~=1)) %both a and b are working
        if (i< p*l/(p*l+ma+mb))
          arrivals_counter = arrivals_counter + 1;
          arrivals_ab(state+1) = arrivals_ab(state+1) +1;
          state = state +1;
         elseif ((i>=(l/(l+ma+mb))) && (i<((ma+p*l)/(l+ma+mb)))) %departure from a
          upper_chain = 0;
          state = state -1;
         else %departure from b
          upper_chain = 1;
          state = state - 1;
        end
      elseif ((state == 1) && (upper_chain == 0)) %State 1, both are working
        if (i< p*l/(p*l+mb)) %Arrival
          arrivals_counter = arrivals_counter + 1;
          arrivals_ab(state+1)=arrivals_ab(state+1)+1;
          state = state + 1;
        else %Departure from b 
          state = state -1;
          upper_chain=1;
        end
      elseif ((state>k+1) && (upper_chain == 0)) %>k+1, both are working
        if (i < p*l/(p*l+ma+mb))
          arrivals_counter = arrivals_counter +1;
          arrivals_ab(state+1) = arrivals_ab(state+1) +1;
          state = state+1;
        else
          state = state -1;
        end
      end
      total_counter = total_counter+1;
      if ((mod(total_counter,1000) == 0))
        conversion_old = conversion_new;
        conversion_new = 0;
        for iter = 1:1:12
          prob_arrival_a(iter)=arrivals_a(iter)/arrivals_counter;
          prob_arrival_ab(iter)=arrivals_ab(iter)/arrivals_counter;
          conversion_new = conversion_new + (iter-1)*(prob_arrival_a(iter) +
          prob_arrival_ab(iter));
        end
        averages_vector=[averages_vector conversion_new];
        %Count new mean values
        totalcounter_vector = [totalcounter_vector total_counter];
       end
    end
    k
    l
    total_counter
    totalcounter_vector;
    averages_k = [averages_k averages_vector(end)];
    figure();
    plot(totalcounter_vector,averages_vector);
    grid();
    title(['lambda=',int2str(l),' k=',int2str(k)]);
    ylabel('Mean Value of clients');
    xlabel('Number of iterations');
    Pa = 1-(prob_arrival_a(1) + prob_arrival_ab(2));%πιθανότητα να εξυπηρετεί ο Α
    ga = Pa*ma; % ρυθμαπόδοση Α
    ga_k=[ga_k ga];
    Pb=0; %πιθανότητα να εξυπηρετεί ο Β
    for j=2:1:12
      Pb = Pb+prob_arrival_ab(j);
    end
    gb=Pb*mb;
    gb_k=[gb_k gb];
  end
  g_ratio= ga_k./gb_k
  figure();
  plot(k_vector,averages_k);
  grid();
  title(['Mean Value according to k for lambda=',int2str(l)]);
  ylabel('Mean value of clients');
  xlabel('k');
  figure();
  plot(k_vector,ga_k);
  grid();
  title(['Throughput of a according to k for lambda=',int2str(l)]);
  ylabel('Throughput a');
  xlabel('k');
  figure();
  plot(k_vector,gb_k);
  grid();
  title(['Throughput of b according to k for lambda=',int2str(l)]);
  ylabel('Throughput b');
  xlabel('k');
  figure();
  plot(k_vector,g_ratio);
  grid();
  title(['Throughput a/Throughput b according to k for lambda=',int2str(l)]);
  ylabel('Thtoughput a / throughput b');
  xlabel('k');
end