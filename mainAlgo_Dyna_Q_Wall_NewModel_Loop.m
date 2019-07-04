clear all; close all; clc;
global row col start goal wall gamma alpha epsilon N_Episode Step_Count ...
    Monitoring_SW N_Dyna
while(1)
    Monitoring_SW = 0; % Off: 0, ON : 1
    H = 1;
    step_save = zeros(1,H);
    for Again = 1:H  % Let do again til H
        
        %% Initialization
        % Size of grid world
        row = 6;         col = 9;
        
        % Start and End Point
        start.row = 3;         start.col = 1;         start;
        
        goal.row = 1;         goal.col = 9;         goal;
        
        % wall
        wall = [0 0 0 0 0 0 0 1 0 ;
            0 0 1 0 0 0 0 1 0 ;
            0 0 1 0 0 0 0 1 0 ;
            0 0 1 0 0 0 0 0 0 ;
            0 0 0 0 0 1 0 0 0 ;
            0 0 0 0 0 0 0 0 0 ;];
        
        % RL parameter
        gamma = 0.95;         alpha = 0.1;         epsilon = 0.1;
        Step_Count= inf;         N_Episode = 100;
        N_Dyna = 10000; % Number of Simulation Loop
        N_decision = 4;
        
        % Reward
        rewardhold = 0;         rewardpos = 1;         rewardneg = 0;
        
        % Variables
        Q= zeros(row,col,4);
        newQ= ones(row,col,4) * inf; %for convergence
        temp= zeros(row,col,N_decision); %temp array for printing purpose
        Pssa= zeros(row,col,1);
        Rsa= zeros(row,col,1);
        Reward_save = zeros(1,1);
        Reward_mean = zeros(1,1);
        Rewardsum = 0;         action=0;         add=1;         sumsumQ = 0;
        iteration = 1; iteration_old = 1; Dyna_step = 1;
        rewardVector= zeros(1,N_Episode);
        Model_old = zeros(1,6);         step_old = inf;
        
        close all;
        if Monitoring_SW == 1
            figure('color','w');
        end
        %% Start
        for count = 1:N_Episode
            %     if iteration > 1000, Monitoring_SW = 1; end
            Model = zeros(1,6);
            current=start;
            step = 1;
            randN = 0 + (rand(1) * 1); % generating random double between 0 and 1
            
            if(randN > epsilon) %greedy
                [maxQ,action] = max(Q(current.row,current.col,:)); %get next pos
            else
                action = round(1 + (rand(1) * 3)); %random integer between 1 and 4
            end
            
            % For monitoring
            if Monitoring_SW == 1
                hold off;
                CreateGrid(row,col,start,goal); hold on;
            end
            
            %% Loop for each steps of Episode
            while (isOverlap(current,goal) ~= 0 ) % until goal is reached
                if (step > Step_Count) %limited steps
                    break;
                end
                
                [next, temp] = getNext(current, action, wall,temp, row, col);
                if isOverlap(next,goal) ~= 0
                    reward = rewardhold;
                    if wall(next.row,next.col) == 1, % Wall
                        reward = rewardneg;
                    end
                else
                    reward = rewardpos;
                end
                
                [maxQ, nextAction] = max(Q(next.row, next.col, :));
                randN = 0 + (rand(1) * 1); % Epsilon Greedy
                if(randN <= epsilon)
                    nextAction = round(1 + (rand(1) * 3));
                end
                
                % Q-learning
                currentQ = Q(current.row, current.col, action);
                Q(current.row, current.col, action) = currentQ + alpha* (reward + (gamma*maxQ) - currentQ);
                
                % Model learning (current, action, reward, next; t = step)
                Model(step,:) = [current.row current.col action reward next.row next.col];
                
                % Monitoring for each step
                if Monitoring_SW == 1
                    setPoint(current.row, current.col, row,col);
                    title(sprintf('Artificial intelligence\n Reinforcement learning\nStep = %d, Iteration = %d, Reward = %d', step, iteration, Rewardsum));
                    drawnow;
                end
                % monitoring Q matrix
                for k=1:row,
                    for j=1:col,
                        [argvalue, argmax] = max(Q(k,j,:));
                        Q_save(k,j) = argmax;
                    end
                end
                
                rewardVector(1,iteration) = reward;
                Rewardsum = Rewardsum + reward;
                current = next;
                action = nextAction;
                step = step + 1;
                add = add + 1;
            end
            if step <= step_old,
                Model_out = Model;
            else
                Model_out = Model_old;
            end
            
            %additional step to be added after goal state reached
            [next, temp] = getNext(current, action, wall,temp, row, col);
            if isOverlap(next,goal) ~= 0
                rewardNew = rewardhold;
                if next.row == row && next.col >= 2 && next.col < col, % Cliff
                    rewardNew = rewardneg;
                end
            else
                rewardNew = rewardpos;
            end
            
            Rewardsum = Rewardsum + rewardNew;
            
            step_save(iteration,Again) = step;
            Reward_save(iteration) = Rewardsum;
            Reward_mean(iteration) = Rewardsum/step;
            Rewardsum = 0;
            
            [maxQ, nextAction] = max(Q(next.row, next.col, :));
            currentQ = Q(current.row, current.col, action);
            Q(current.row, current.col, action) = currentQ + alpha* (rewardNew + (gamma*maxQ) - currentQ);
            
            %converge here--------------------
            ModelAnalysis = [start.row, start.col, Reward_save(iteration), iteration];
            sumsumabsQ = sum(sum(sum(abs(newQ-Q))));
            sumsumQ(iteration) = sumsumabsQ;
            if sumsumabsQ < 0.1 || (iteration > N_Episode)
                temp2 = printEpisode(Q,row,col,start,goal,wall,step_save(:,Again),N_decision,iteration);
                break;
            else
                newQ=Q;
            end
            
            iteration_old = iteration;
            iteration = iteration + 1;
            Model_old = Model;
            step_old = step;
            %% Loop repeat n times (Simulation by learnt model)
            Model = Model_out;
            Vt = zeros(row,col,N_decision);     Rt = zeros(row,col);
            [rN, rZ] =size(Model);
            for k=1:rN  % Make MDP model
                if Model(k,4) == 1, Rt(Model(k,5),Model(k,6)) = 1; end
                Vt(Model(k,1),Model(k,2),Model(k,3)) = ...
                    Vt(Model(k,1),Model(k,2),Model(k,3))+1; % state action
            end
            A = randperm(rN,rN)';
            if(iteration_old ~= iteration)
                for Dyna_step = 1:N_Dyna
                    if Dyna_step >= rN, k = A(mod(Dyna_step,rN)+1);
                    else, k = A(Dyna_step);
                    end
                    current.row = Model(k,1); current.col = Model(k,2);
                    while(1) % Random action
                        j = round(1 + (rand(1) * 3));
                        if  Vt(current.row,current.col,j)~= 0, action = j; break; end
                    end
                    %             [~, action] = max(Vt(current.row,current.col,:));
                    [next, ~] = getNext(current, action, wall,temp, row, col);
                    reward= Rt(next.row,next.col);
                    % Q-learning
                    rewardNew = reward;
                    [maxQ, ~] = max(Q(next.row, next.col, :));
                    currentQ = Q(current.row, current.col, action);
                    Q(current.row, current.col, action) = currentQ + alpha* (rewardNew + (gamma*maxQ) - currentQ);
                end
                
            end
        end
        
    end
    for k=1:length(step_save)
        Output(k) = mean(step_save(k,:));
    end
    figure('color','w'); plot(Output);
    axis([2 50 0 1000])
    xlabel('Episodes'); ylabel('Steps per episodes');
    Output = Output';
    break;
end

function var = isOverlap(first,second)
var = first.row - second.row;
if (var == 0)
    var = first.col - second.col;
end
end

function [pos, temp] = getNext(current, action, wall, temp, row, col)
actIndex = action;
pos = current;
switch action
    case 1 %east
        pos.col= current.col + 1;
    case 2 %south
        pos.row= current.row + 1;
    case 3 %west
        pos.col= current.col - 1;
    case 4 %north
        pos.row= current.row - 1;
end
if pos.col <= 0,  pos.col = 1; end
if pos.col > col, pos.col = col; end
if pos.row <= 0,  pos.row = 1; end
if pos.row > row, pos.row = row; end
if (wall(pos.row, pos.col) == 1)
    pos.col = current.col;
    pos.row = current.row;
end

%----- updating temp array for printing purpose
temp(current.row, current.col, actIndex) = 1;
%-------------------------
end

function temp2 = printEpisode(Q,row,col,start,goal,wall,step,N_decision,iteration)
temp2 = zeros(row,col,N_decision);
current= start;
'Optimal Path :';
'Start';
current;
for i = 1: 100
    [tempMax, act2] = max(Q(current.row,current.col,:));
    [next, temp2] = getNext(current, act2, wall,temp2, row, col);
    
    temp2;
    act2;
    next;
    if (isOverlap(next,goal) == 0)
        'Reached Goal';
        break;
    end
    current = next;
end

figure('Name',sprintf('Episode: %d', iteration), 'NumberTitle','off');
ParseArrows(temp2, row, col,start,goal);
% title(sprintf('wally grid-world, Converges on steps - %d ', step));
end

function setPoint(x,y, matrixRow,matrixCol)
xsp = 1 / (matrixCol + 2);
ysp = 1 / (matrixRow + 2);
xcor = ((2*y + 1) / 2) * xsp;
ycor = 1 - (((2*x + 1) / 2) * ysp);
xcor = xcor - xsp/5;
plot(xcor,ycor, 'x','markersize',10,'linewidth',2);
end
